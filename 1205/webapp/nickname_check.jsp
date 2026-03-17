<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="util.DBConnection" %>
<%
    String nickname = request.getParameter("nickname");

    response.setContentType("text/plain");

    if (nickname == null || nickname.trim().isEmpty()) {
        out.print("error:닉네임을 입력하세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean isDuplicated = false;

    try {
        conn = DBConnection.getConnection();
        
        String sql = "SELECT COUNT(*) FROM member WHERE nickname = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, nickname);
        
        rs = pstmt.executeQuery();

        if (rs.next()) {
            int count = rs.getInt(1);
            if (count > 0) {
                isDuplicated = true;
            }
        }

        if (isDuplicated) {
            out.print("false");
        } else {
            out.print("true");
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