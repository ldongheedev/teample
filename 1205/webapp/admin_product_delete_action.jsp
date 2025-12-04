<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");
    // 1. 관리자 권한 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("관리자 권한이 없습니다.");
            location.href = "main_page.jsp";
        </script>
<%
        return;
    }
    
    String[] idsToDelete = request.getParameterValues("product_id");
    if (idsToDelete == null || idsToDelete.length == 0) {
%>
        <script>
            alert("삭제할 상품을 선택하지 않았습니다.");
            history.back();
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement notiPstmt = null; // ✨ 알림용 pstmt
    ArrayList<String> filesToDelete = new ArrayList<>();
    int deleteCount = 0;
    
    // ✨ 알림 SQL 준비
    String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, 'DELETE', ?, 'customer?cmd=inquiryList', NOW())";

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 쿼리 준비
        String sqlSelectImages = "SELECT image_url FROM ProductImage WHERE product_id = ?";
        String sqlSelectMainImage = "SELECT main_image_url FROM Product WHERE product_id = ?";
        String sqlSelectInfo = "SELECT user_id, product_name FROM Product WHERE product_id = ?";
        
        String sqlDeleteImages = "DELETE FROM ProductImage WHERE product_id = ?";
        String sqlDeleteWishlist = "DELETE FROM Wishlist WHERE product_id = ?";
        String sqlDeleteTrade = "DELETE FROM TradeRequest WHERE product_id = ?";
        String sqlDeleteProduct = "DELETE FROM Product WHERE product_id = ?";

        for (String idStr : idsToDelete) {
            int productId = Integer.parseInt(idStr);
            
            // 0. 삭제 전 판매자 정보 조회 및 알림 발송
            pstmt = conn.prepareStatement(sqlSelectInfo);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String sellerId = rs.getString("user_id");
                String pName = rs.getString("product_name");
                
                String message = "운영 정책 위반으로 귀하의 상품 '" + pName + "' 이(가) 관리자에 의해 삭제되었습니다.";
                
                // ✨ [수정] 같은 conn 사용
                notiPstmt = conn.prepareStatement(notiSql);
                notiPstmt.setString(1, sellerId);
                notiPstmt.setString(2, message);
                notiPstmt.executeUpdate();
                notiPstmt.close();
            }
            rs.close();
            pstmt.close();

            // 1. 파일 삭제를 위해 이미지 경로 미리 조회
            pstmt = conn.prepareStatement(sqlSelectImages);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String path = rs.getString("image_url");
                if (path != null && !path.isEmpty()) filesToDelete.add(path);
            }
            rs.close();
            pstmt.close();

            // 2. 대표 이미지 경로 조회
            pstmt = conn.prepareStatement(sqlSelectMainImage);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String path = rs.getString("main_image_url");
                if (path != null && !path.isEmpty()) filesToDelete.add(path);
            }
            rs.close();
            pstmt.close();
            
            // 3. 자식 데이터들부터 삭제
            pstmt = conn.prepareStatement(sqlDeleteWishlist);
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
            pstmt.close();

            pstmt = conn.prepareStatement(sqlDeleteTrade);
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
            pstmt.close();

            pstmt = conn.prepareStatement(sqlDeleteImages);
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // 4. 최종적으로 상품 삭제
            pstmt = conn.prepareStatement(sqlDeleteProduct);
            pstmt.setInt(1, productId);
            int count = pstmt.executeUpdate();
            deleteCount += count;
            pstmt.close();
        }
        
        conn.commit(); // 커밋

    } catch (Exception e) {
        if (conn != null) { try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } }
        e.printStackTrace();
%>
        <script>
            alert("상품 삭제 중 DB 오류 발생: <%= e.getMessage().replace("'", "\\'") %>");
            history.back();
        </script>
<%
        return;
    } finally {
        if (notiPstmt != null) try { notiPstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); } }
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // 5. 실제 파일 삭제
    try {
        for (String filePath : filesToDelete) {
            String physicalPath = application.getRealPath(filePath);
            File file = new File(physicalPath);
            if (file.exists()) {
                file.delete();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    session.setAttribute("toastMessage", "관리자 권한으로 " + deleteCount + "개의 상품을 삭제했습니다.");
    response.sendRedirect("admin_product_list.jsp");
%>