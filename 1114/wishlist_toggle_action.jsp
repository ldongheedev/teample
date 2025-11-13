<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    String productIdStr = request.getParameter("product_id");

    // 1. 로그인 확인
    if (userId == null) {
        // 로그인되지 않은 사용자는 세션이 없으므로 "userId" 속성이 null입니다.
        out.print("{\"status\": \"error\", \"message\": \"로그인이 필요합니다.\"}");
        return;
    }

    // 2. 상품 ID 파라미터 확인
    if (productIdStr == null || productIdStr.isEmpty()) {
        out.print("{\"status\": \"error\", \"message\": \"상품 ID가 없습니다.\"}");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(productIdStr);
    } catch (NumberFormatException e) {
        out.print("{\"status\": \"error\", \"message\": \"유효하지 않은 상품 ID입니다.\"}");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        // 트랜잭션 관리 시작
        conn.setAutoCommit(false);

        // 3. 자신의 상품인지 확인 (자신의 상품은 찜 불가)
        String checkOwnerSql = "SELECT user_id FROM Product WHERE product_id = ?";
        pstmt = conn.prepareStatement(checkOwnerSql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            if (userId.equals(rs.getString("user_id"))) {
                // 찜하려는 상품이 자신의 상품일 경우
                out.print("{\"status\": \"error\", \"message\": \"자신의 상품은 찜할 수 없습니다.\"}");
                conn.rollback(); // 트랜잭션 롤백
                return;
            }
        } else {
            // 상품 ID에 해당하는 상품이 DB에 없는 경우
            out.print("{\"status\": \"error\", \"message\": \"존재하지 않는 상품입니다.\"}");
            conn.rollback(); // 트랜잭션 롤백
            return;
        }

        // 4. 이미 찜한 상품인지 확인
        String checkSql = "SELECT wishlist_id FROM Wishlist WHERE user_id = ? AND product_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, userId);
        pstmt.setInt(2, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 5-1. 이미 찜함 -> 찜 해제 (DELETE)
            String deleteSql = "DELETE FROM Wishlist WHERE user_id = ? AND product_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);
            pstmt.executeUpdate();
            
            conn.commit(); // 트랜잭션 완료
            out.print("{\"status\": \"removed\", \"message\": \"찜 목록에서 제거했습니다.\"}");

        } else {
            // 5-2. 찜하지 않음 -> 찜 추가 (INSERT)
            String insertSql = "INSERT INTO Wishlist (user_id, product_id) VALUES (?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);
            pstmt.executeUpdate();
            
            conn.commit(); // 트랜잭션 완료
            out.print("{\"status\": \"added\", \"message\": \"찜 목록에 추가했습니다.\"}");
        }

    } catch (Exception e) {
        // 예외 발생 시 롤백
        if (conn != null) {
            try { 
                conn.rollback(); 
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        e.printStackTrace();
        
        // JSON 문자열이 깨지지 않도록 메시지 내부의 " 문자를 \"로 치환
        String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "알 수 없는 오류";
        out.print("{\"status\": \"error\", \"message\": \"처리 중 오류 발생: " + errorMsg + "\"}");
        
    } finally {
        // 리소스 정리 (AutoCloseable을 사용하지 않으므로 finally에서 명시적 close)
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { 
            conn.setAutoCommit(true); // 커넥션 풀 반환 전 기본값으로 복원
            conn.close(); 
        } catch (SQLException ignore) {}
    }

    // 각 분기문에서 이미 out.print()로 JSON 응답을 보냈으므로
    // 이 JSP 파일 자체는 최종적으로 아무것도 출력하지 않아야 함.
    out.flush();
%>