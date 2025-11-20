<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sellerId = (String) session.getAttribute("userId");
    String tradeIdStr = request.getParameter("trade_id");
    String action = request.getParameter("action"); // "accept" 또는 "reject"

    if (sellerId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    if (tradeIdStr == null || action == null) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    int tradeId = Integer.parseInt(tradeIdStr);
    String newStatus = "";
    String successMessage = "";

    if ("accept".equals(action)) {
        newStatus = "ACCEPTED";
        successMessage = "거래를 수락했습니다.";
    } else if ("reject".equals(action)) {
        newStatus = "REJECTED";
        successMessage = "거래를 거절했습니다.";
    } else {
        out.println("<script>alert('알 수 없는 작업입니다.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "UPDATE TradeRequest SET status = ?, accepted_at = CURRENT_TIMESTAMP " +
                     "WHERE trade_id = ? AND seller_id = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, newStatus);
        pstmt.setInt(2, tradeId);
        pstmt.setString(3, sellerId); // (보안) 본인(판매자)의 거래 요청이 맞는지 재확인

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            out.println("<script>alert('" + successMessage + "'); location.href='notifications.jsp';</script>");
        } else {
            out.println("<script>alert('요청을 처리할 수 없거나 이미 처리된 요청입니다.'); location.href='notifications.jsp';</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('처리 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>