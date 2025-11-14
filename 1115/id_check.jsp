<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%
    String id = request.getParameter("id"); // 1. 'nickname' -> 'id'로 변경

    response.setContentType("text/plain");

    if (id == null || id.trim().isEmpty()) {
        out.print("error:아이디를 입력하세요."); // 2. 메시지 변경
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean isDuplicated = false;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234"
        );
        
        String sql = "SELECT COUNT(*) FROM member WHERE id = ?"; // 3. 쿼리 변경 (WHERE nickname -> WHERE id)
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int count = rs.getInt(1);
            if (count > 0) {
                isDuplicated = true;
            }
        }

        if (isDuplicated) {
            out.print("false"); // 이미 존재함
        } else {
            out.print("true"); // 사용 가능함
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("error:DB 처리 중 오류가 발생했습니다.");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

%>


