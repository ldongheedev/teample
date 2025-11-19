<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // status는 테이블 생성 시 Default로 'WAITING'이 들어가므로 쿼리에서 생략 가능하지만, 명시적으로 넣습니다.
        String sql = "INSERT INTO Inquiry (user_id, category, title, content, status, created_at) VALUES (?, ?, ?, ?, 'WAITING', NOW())";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, category);
        pstmt.setString(3, title);
        pstmt.setString(4, content);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            out.println("<script>alert('문의가 정상적으로 등록되었습니다.'); location.href='inquiry_list.jsp';</script>");
        } else {
            out.println("<script>alert('등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>