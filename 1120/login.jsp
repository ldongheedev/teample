<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    request.setCharacterEncoding("UTF-8");

    String id = request.getParameter("id");
    String pw = request.getParameter("pw");
    
    // 폼 제출이 아닌 단순 페이지 로드 시에는 아래 로직을 실행하지 않음
    if (id == null || id.trim().isEmpty()) {
        return; 
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 1. ID와 PW로 회원 정보 조회 (정지 상태와 정지 해제 날짜 포함)
        // 비밀번호 컬럼 이름을 'pw'로 가정하고 수정했습니다. (이전 오류 해결에 기반)
        String sql = "SELECT id, nickname, isAdmin, status, suspension_end_date FROM member WHERE id = ? AND pw = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setString(2, pw); 
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 2. 로그인 정보 일치 확인
            
            String status = rs.getString("status");
            Timestamp suspendEnd = rs.getTimestamp("suspension_end_date");
            
            // ✨ 정지 상태 체크 시작
            boolean isStillSuspended = "SUSPENDED".equals(status);

            if (isStillSuspended) {
                if (suspendEnd != null) {
                    Date now = new Date();
                    // 현재 시간이 정지 해제 날짜보다 지났는지 확인
                    if (now.after(suspendEnd)) {
                        // 정지 기간 만료 -> 자동 해제
                        PreparedStatement updatePstmt = null;
                        try {
                            String releaseSql = "UPDATE member SET status = 'ACTIVE', suspension_end_date = NULL WHERE id = ?";
                            updatePstmt = conn.prepareStatement(releaseSql);
                            updatePstmt.setString(1, id);
                            updatePstmt.executeUpdate();
                        } finally {
                            if (updatePstmt != null) updatePstmt.close();
                        }
                        isStillSuspended = false; // 정지 해제 -> 로그인 허용
                    }
                }

                // 여전히 정지 상태라면 로그인 차단
                if (isStillSuspended) {
                    String msg = "정지된 계정입니다. ";
                    if (suspendEnd != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy년 MM월 dd일 HH시 mm분");
                        msg = "해당 계정은 [" + sdf.format(suspendEnd) + "] 까지 이용이 정지되었습니다.";
                    } else {
                        msg = "해당 계정은 '영구 정지' 상태입니다. 관리자에게 문의하세요.";
                    }
%>
                    <script>
                        alert("<%= msg %>");
                        // ✅ 요청하신 대로 메인 페이지로 이동하도록 수정
                        location.href='main_page.jsp'; 
                    </script>
<%
                    return; // 로그인 처리 중단
                }
            }
            // ✨ 정지 상태 체크 종료

            // 3. 로그인 성공 및 세션 저장
            session.setAttribute("userId", rs.getString("id"));
            session.setAttribute("userName", rs.getString("nickname"));
            
            // 관리자 확인 로직
            // -----------------------------------------------------------------
            String adminId = "rk0329"; // 사용자님의 관리자 아이디
            // -----------------------------------------------------------------
            
            if (rs.getString("id").equals(adminId)) {
                session.setAttribute("isAdmin", "true");
            } else {
                session.setAttribute("isAdmin", "false");
            }
            
            // 4. 리다이렉트
            response.sendRedirect("main_page.jsp"); 
            return;
        }
        
    } catch(Exception e) {
        e.printStackTrace();
%>
    <script>
        alert('로그인 중 서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        history.back();
    </script>
<%
        return; 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
<script>
    // 이 코드는 로그인 실패 (ID/PW 불일치) 시에만 실행됩니다.
    alert('아이디 또는 비밀번호를 확인해주세요!');
    history.back();
</script>
</body>
</html>