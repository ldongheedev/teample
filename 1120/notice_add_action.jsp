<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%
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

    request.setCharacterEncoding("UTF-8");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String writerId = request.getParameter("writer_id"); 
    
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
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "INSERT INTO Notice (title, content, writer_id) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setString(3, writerId);
        
        int count = pstmt.executeUpdate();
        
        if (count > 0) {
            // ✨ 1. 세션에 토스트 메시지 저장
            session.setAttribute("toastMessage", "공지사항이 성공적으로 등록되었습니다.");
            // ✨ 2. alert 대신 sendRedirect 사용
            response.sendRedirect("notice_list.jsp");
        } else {
%>
            <script>
                alert('공지사항 등록에 실패했습니다. 다시 시도해 주세요.');
                history.back();
            </script>
<%
        }
        
    } catch(Exception e) {
        e.printStackTrace();
%>
        <script>
            alert('DB 처리 중 오류가 발생했습니다. 관리자에게 문의하세요.');
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>