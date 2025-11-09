<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%
    // ✨ 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("관리자 권한이 없습니다.");
            history.back(); 
        </script>
<%
        return;
    }

    // 2. 폼 데이터 받기
    request.setCharacterEncoding("UTF-8");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String writerId = request.getParameter("writer_id"); // form의 hidden 필드에서 받음
    
    // 필수 입력값 검증 (스크립트에서 했지만 서버에서 한 번 더 체크)
    if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty() || writerId == null || writerId.trim().isEmpty()) {
%>
        <script>
            alert("제목과 내용을 모두 입력해주세요.");
            history.back();
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // 3. DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 4. INSERT 쿼리 실행
        // reg_date는 DEFAULT CURRENT_TIMESTAMP로 설정되어 있으므로 쿼리에서 생략합니다.
        // views는 DEFAULT 0으로 설정되어 있으므로 쿼리에서 생략합니다.
        String sql = "INSERT INTO Notice (title, content, writer_id) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setString(3, writerId);
        
        int count = pstmt.executeUpdate();
        
        if (count > 0) {
%>
            <script>
                alert('공지사항이 성공적으로 등록되었습니다.');
                // ✨ 요청하신 대로 공지사항 목록 페이지로 이동합니다.
                location.href = 'notice_list.jsp'; 
            </script>
<%
        } else {
%>
            <script>
                alert('공지사항 등록에 실패했습니다. 다시 시도해 주세요.');
                history.back();
            </script>
<%
        }
        
    } catch(SQLException | ClassNotFoundException e) {
        e.printStackTrace();
%>
        <script>
            alert('DB 처리 중 오류가 발생했습니다. 관리자에게 문의하세요.');
            history.back();
        </script>
<%
    } catch(UnsupportedEncodingException e) {
        e.printStackTrace();
%>
        <script>
            alert('데이터 인코딩 중 오류가 발생했습니다.');
            history.back();
        </script>
<%
    } finally {
        // 5. 자원 정리
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>