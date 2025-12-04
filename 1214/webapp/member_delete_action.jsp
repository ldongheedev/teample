<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        // (로그인되지 않은 경우)
        response.sendRedirect("loginpage.jsp");
        return;
    }

    // ✨ 관리자 탈퇴 방지 로직 추가
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin != null && isAdmin.equals("true")) {
        // 관리자 계정은 탈퇴할 수 없음을 알리고 마이페이지로 리다이렉트
        session.setAttribute("toastMessage", "관리자 계정은 탈퇴할 수 없습니다.");
        response.sendRedirect("mypage.jsp");
        return; 
    }
    // ✨ 관리자 탈퇴 방지 로직 추가 끝

    // 2. 폼에서 전송된 '현재 비밀번호' 받기
    String currentPassword = request.getParameter("current_pw");
    if (currentPassword == null || currentPassword.trim().isEmpty()) {
        // (비밀번호가 비어있는 비정상적 접근)
        session.setAttribute("toastMessage", "비밀번호가 필요합니다.");
        response.sendRedirect("member_delete_form.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // --- 3. 비밀번호 검증 (DB 구조에 맞춰 salt 없이 조회) ---
        String sql = "SELECT pw FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            String storedPassword = rs.getString("pw"); // DB에 저장된 원본 비밀번호

            // --- 4. 비밀번호 일치 여부 확인 (원본 텍스트끼리 비교) ---
            if (storedPassword.equals(currentPassword)) {
                // [비밀번호 일치] - 탈퇴 트랜잭션 시작
                
                // 4-1. 트랜잭션 시작 (Auto-commit 해제)
                conn.setAutoCommit(false);
                
                try {
                    // 4-2. (무결성) 회원이 등록한 상품 먼저 삭제 (Product 테이블의 FK 제약조건)
                    sql = "DELETE FROM Product WHERE user_id = ?";
                    pstmt.close(); // 이전 pstmt 닫기
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userId);
                    pstmt.executeUpdate();

                    // 4-3. (핵심) 회원 정보 삭제
                    sql = "DELETE FROM member WHERE id = ?";
                    pstmt.close(); // 이전 pstmt 닫기
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userId);
                    int deleteCount = pstmt.executeUpdate();

                    // 4-4. 모든 작업 성공 시 'Commit'
                    conn.commit();

                    // 4-5. 로그아웃 (세션 무효화)
                    session.invalidate();
                    
                    // 4-6. 탈퇴 완료 메시지를 '새 세션'에 담아 메인으로 리다이렉트
                    session = request.getSession(true); // 새 세션 시작
                    session.setAttribute("toastMessage", "회원 탈퇴가 완료되었습니다. 이용해주셔서 감사합니다.");
                    response.sendRedirect("main_page.jsp");
                    return; // 리다이렉트 후 즉시 코드 실행 종료

                } catch (SQLException e_tx) {
                    // [트랜잭션 오류]
                    conn.rollback(); // 모든 작업 롤백
                    throw e_tx; // 바깥쪽 catch 블록으로 예외 던지기
                }

            } else {
                // [비밀번호 불일치]
                session.setAttribute("toastMessage", "비밀번호가 일치하지 않습니다.");
                response.sendRedirect("member_delete_form.jsp");
                return;
            }

        } else {
            // (있을 수 없는 일) 로그인된 사용자가 DB에 없음
            throw new Exception("세션 정보와 일치하는 사용자가 없습니다.");
        }

    } catch (Exception e) {
        // [DB 연결 오류 또는 트랜잭션 오류]
        e.printStackTrace();
        session.setAttribute("toastMessage", "탈퇴 처리 중 오류가 발생했습니다. 관리자에게 문의하세요.");
        response.sendRedirect("member_delete_form.jsp");
        
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        // Auto-commit을 원상 복구 (커넥션 풀 반환 시 중요)
        if (conn != null) {
            try { 
                conn.setAutoCommit(true);
                conn.close(); 
            } catch (SQLException ignore) {}
        }
    }
%>