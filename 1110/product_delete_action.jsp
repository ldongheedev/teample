<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "loginpage.jsp";
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
    ArrayList<String> filesToDelete = new ArrayList<>();
    int deleteCount = 0;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); 

        String sqlSelectImages = "SELECT image_url FROM ProductImage WHERE product_id = ?";
        String sqlSelectMainImage = "SELECT main_image_url FROM Product WHERE product_id = ? AND user_id = ?";
        String sqlDeleteProduct = "DELETE FROM Product WHERE product_id = ? AND user_id = ?";

        for (String idStr : idsToDelete) {
            int productId = Integer.parseInt(idStr);
            
            pstmt = conn.prepareStatement(sqlSelectMainImage);
            pstmt.setInt(1, productId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String mainImg = rs.getString("main_image_url");
                if (mainImg != null && !mainImg.isEmpty()) {
                    filesToDelete.add(mainImg);
                }
            }
            rs.close();
            pstmt.close();

            pstmt = conn.prepareStatement(sqlSelectImages);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String detailImg = rs.getString("image_url");
                if (detailImg != null && !detailImg.isEmpty()) {
                    filesToDelete.add(detailImg);
                }
            }
            rs.close();
            pstmt.close();
            
            pstmt = conn.prepareStatement(sqlDeleteProduct);
            pstmt.setInt(1, productId);
            pstmt.setString(2, userId);
            int count = pstmt.executeUpdate();
            deleteCount += count;
            pstmt.close();
        }
        
        conn.commit(); 

    } catch (Exception e) {
        if (conn != null) { try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } }
        e.printStackTrace();
%>
        <script>
            alert("상품 삭제 중 오류가 발생했습니다: <%= e.getMessage().replace("'", "\\'") %>");
            history.back();
        </script>
<%
        return; 
    } finally {
        if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); } }
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

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

    session.setAttribute("toastMessage", deleteCount + "개의 상품이 성공적으로 삭제되었습니다.");
    response.sendRedirect("mypage.jsp");
%>