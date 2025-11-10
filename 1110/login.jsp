<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String id = request.getParameter("id");
    String pw = request.getParameter("pw");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "SELECT * FROM member WHERE id = ? AND pw = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setString(2, pw);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 3. 로그인 성공: 세션에 정보 저장
            session.setAttribute("userId", rs.getString("id"));
            session.setAttribute("userName", rs.getString("nickname"));
            
            // ✨ 1. 관리자 확인 로직 추가
            // -----------------------------------------------------------------
            // ⚠️ 여기에 사용자님의 관리자 아이디를 정확히 입력하세요!
            String adminId = "rk0329"; 
            // -----------------------------------------------------------------
            
            if (rs.getString("id").equals(adminId)) {
                // 세션에 'isAdmin'이라는 이름으로 "true" 값을 저장
                session.setAttribute("isAdmin", "true");
            }
            
            // 4. 리다이렉트
            response.sendRedirect("main_page.jsp"); 
            return;
        }
        
    } catch(Exception e) {
        e.printStackTrace();
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
    alert('아이디 또는 비밀번호를 확인해주세요!');
    history.back();
</script>
</body>
</html>
