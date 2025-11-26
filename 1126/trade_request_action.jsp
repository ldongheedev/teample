<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%
    // 1. (보안) 구매자 ID (로그인한 사용자)
    String buyerId = (String) session.getAttribute("userId");
    
    // 2. 폼에서 전송된 상품 ID
    String productIdStr = request.getParameter("product_id");

    // --- 유효성 검사 1: 로그인 확인 ---
    if (buyerId == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401 Error
        out.print("{\"status\": \"error\", \"message\": \"로그인이 필요합니다.\"}");
        return;
    }

    // --- 유효성 검사 2: 상품 ID 확인 ---
    if (productIdStr == null || productIdStr.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Error
        out.print("{\"status\": \"error\", \"message\": \"상품 ID가 없습니다.\"}");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(productIdStr);
    } catch (NumberFormatException e) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Error
        out.print("{\"status\": \"error\", \"message\": \"유효하지 않은 상품 ID입니다.\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sellerId = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 3. 상품 정보 조회 (판매자 ID 확인 및 자신의 상품인지 확인)
        String sqlCheckProduct = "SELECT user_id FROM Product WHERE product_id = ?";
        pstmt = conn.prepareStatement(sqlCheckProduct);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            sellerId = rs.getString("user_id");
            
            // --- 유효성 검사 3: 자신의 상품 구매 방지 ---
            if (buyerId.equals(sellerId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN); // 403 Error
                out.print("{\"status\": \"error\", \"message\": \"자신의 상품은 구매할 수 없습니다.\"}");
                conn.rollback();
                return;
            }
        } else {
            // --- 유효성 검사 4: 상품 존재 확인 ---
            response.setStatus(HttpServletResponse.SC_NOT_FOUND); // 404 Error
            out.print("{\"status\": \"error\", \"message\": \"존재하지 않는 상품입니다.\"}");
            conn.rollback();
            return;
        }
        rs.close();
        pstmt.close();

        // 4. 중복 요청 확인
        // (MySQL/MariaDB의 UNIQUE KEY 제약 조건을 활용할 수도 있지만, 
        //  여기서는 명시적으로 확인하여 사용자에게 친절한 메시지를 보냅니다.)
        String sqlCheckDuplicate = "SELECT trade_id FROM TradeRequest WHERE product_id = ? AND buyer_id = ?";
        pstmt = conn.prepareStatement(sqlCheckDuplicate);
        pstmt.setInt(1, productId);
        pstmt.setString(2, buyerId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // --- 유효성 검사 5: 중복 요청 방지 ---
            response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Error
            out.print("{\"status\": \"error\", \"message\": \"이미 구매 요청을 하신 상품입니다.\"}");
            conn.rollback();
            return;
        }
        rs.close();
        pstmt.close();

        // 5. (최종 통과) 거래 요청 INSERT
        String sqlInsert = "INSERT INTO TradeRequest (product_id, buyer_id, seller_id, status) VALUES (?, ?, ?, 'REQUESTED')";
        pstmt = conn.prepareStatement(sqlInsert);
        pstmt.setInt(1, productId);
        pstmt.setString(2, buyerId);
        pstmt.setString(3, sellerId);
        
        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            conn.commit(); // 트랜잭션 완료
            response.setStatus(HttpServletResponse.SC_OK); // 200 Success
            out.print("{\"status\": \"success\", \"message\": \"판매자에게 구매 요청을 보냈습니다.\"}");
        } else {
            throw new SQLException("데이터 삽입에 실패했습니다.");
        }

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
        }
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 Error
        String errorMsg = e.getMessage().replace("\"", "\\\"");
        out.print("{\"status\": \"error\", \"message\": \"처리 중 오류 발생: " + errorMsg + "\"}");
        
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { 
            conn.setAutoCommit(true); 
            conn.close(); 
        } catch (SQLException ignore) {}
    }
%>