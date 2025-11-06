<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%!
    private String getFileName(Part part) {
        if (part == null) return null;
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                String fileName = token.substring(token.indexOf("=") + 2, token.length() - 1);
                return new File(fileName).getName();
            }
        }
        return null;
    }

    private String partToString(Part part) throws java.io.IOException {
        if (part == null) return null;
        InputStream is = part.getInputStream();
        java.util.Scanner s = new java.util.Scanner(is, "UTF-8").useDelimiter("\\A");
        String result = s.hasNext() ? s.next() : "";
        s.close();
        is.close();
        return result;
    }
%>

<%
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("loginpage.jsp");
        return;
    }

    String savePath = "/uploads"; 
    String uploadDir = application.getRealPath(savePath);
    
    File uploadDirFile = new File(uploadDir);
    if (!uploadDirFile.exists()) {
        uploadDirFile.mkdirs();
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String mainImageUrl = null;
    ArrayList<String> detailImageUrls = new ArrayList<>();
    boolean newMainImageUploaded = false;
    boolean newDetailImagesUploaded = false;

    try {
        request.setCharacterEncoding("UTF-8"); 
        
        String productIdStr = partToString(request.getPart("product_id"));
        int productId = Integer.parseInt(productIdStr);
        
        String categoryId = partToString(request.getPart("category_id"));
        String productName = partToString(request.getPart("product_name"));
        String priceStr = partToString(request.getPart("price"));
        String description = partToString(request.getPart("description"));
        String shippingStr = partToString(request.getPart("shipping_included"));

        int price = (priceStr != null && !priceStr.isEmpty()) ? Integer.parseInt(priceStr) : 0;
        boolean shippingIncluded = "true".equals(shippingStr); 
        
        Part mainImagePart = request.getPart("main_image");
        if (mainImagePart != null && mainImagePart.getSize() > 0) {
            String mainImageName = getFileName(mainImagePart);
            if (mainImageName != null && !mainImageName.isEmpty()) {
                mainImagePart.write(uploadDir + File.separator + mainImageName);
                mainImageUrl = savePath + "/" + mainImageName; 
                newMainImageUploaded = true;
            }
        }
        
        for (int i = 1; i <= 4; i++) {
            Part detailImagePart = request.getPart("detail_image" + i);
            if (detailImagePart != null && detailImagePart.getSize() > 0) {
                String detailImageName = getFileName(detailImagePart);
                if (detailImageName != null && !detailImageName.isEmpty()) {
                    detailImagePart.write(uploadDir + File.separator + detailImageName);
                    detailImageUrls.add(savePath + "/" + detailImageName); 
                    newDetailImagesUploaded = true;
                }
            }
        }
        
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); 
        
        StringBuilder sqlUpdate = new StringBuilder("UPDATE Product SET ");
        sqlUpdate.append("category_id = ?, product_name = ?, price = ?, description = ?, shipping_included = ?, updated_at = CURRENT_TIMESTAMP ");
        
        if (newMainImageUploaded) {
            sqlUpdate.append(", main_image_url = ? ");
        }
        
        sqlUpdate.append("WHERE product_id = ? AND user_id = ?");
        
        pstmt = conn.prepareStatement(sqlUpdate.toString());
        
        int paramIndex = 1;
        pstmt.setString(paramIndex++, categoryId);
        pstmt.setString(paramIndex++, productName);
        pstmt.setInt(paramIndex++, price);
        pstmt.setString(paramIndex++, description);
        pstmt.setBoolean(paramIndex++, shippingIncluded);
        
        if (newMainImageUploaded) {
            pstmt.setString(paramIndex++, mainImageUrl);
        }
        
        pstmt.setInt(paramIndex++, productId);
        pstmt.setString(paramIndex++, userId);
        
        int updateCount = pstmt.executeUpdate();
        pstmt.close();
        
        if (updateCount == 0) {
            throw new Exception("상품 수정 권한이 없거나 상품이 존재하지 않습니다.");
        }

        if (newDetailImagesUploaded) {
            String sqlDeleteImages = "DELETE FROM ProductImage WHERE product_id = ?";
            pstmt = conn.prepareStatement(sqlDeleteImages);
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
            pstmt.close();

            String sqlInsertImages = "INSERT INTO ProductImage (product_id, image_url, display_order) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sqlInsertImages);
            for (int i = 0; i < detailImageUrls.size(); i++) {
                pstmt.setInt(1, productId);
                pstmt.setString(2, detailImageUrls.get(i));
                pstmt.setInt(3, i + 1); 
                pstmt.executeUpdate();
            }
        }
        
        conn.commit();
        
        session.setAttribute("toastMessage", "상품이 성공적으로 수정되었습니다.");
        response.sendRedirect("mypage.jsp");

    } catch (Exception e) {
        if (conn != null) { try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } }
        e.printStackTrace();
%>
        <script>
            alert("상품 수정 중 오류가 발생했습니다: <%= e.getMessage().replace("'", "\\'") %>");
            history.back();
        </script>
<%
    } finally {
        if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); } }
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>