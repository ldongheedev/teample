<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="jakarta.servlet.http.Part, java.sql.*, java.util.*, java.io.File, java.io.InputStream"
    trimDirectiveWhitespaces="true" %>

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
    int generatedProductId = -1;
    String errorMessage = null;

    try {
        request.setCharacterEncoding("UTF-8"); 
        
        String categoryId = partToString(request.getPart("category_id"));
        String productName = partToString(request.getPart("product_name"));
        String priceStr = partToString(request.getPart("price"));
        String description = partToString(request.getPart("description"));
        String shippingStr = partToString(request.getPart("shipping_included"));
        
        String isDirectTradeStr = partToString(request.getPart("is_direct_trade"));
        
        int price = (priceStr != null && !priceStr.isEmpty()) ? Integer.parseInt(priceStr) : 0;
        boolean shippingIncluded = "true".equals(shippingStr);
        boolean isDirectTrade = "true".equals(isDirectTradeStr);
        
        Part mainImagePart = request.getPart("main_image");
        if (mainImagePart != null && mainImagePart.getSize() > 0) {
            String mainImageName = getFileName(mainImagePart);
            if (mainImageName != null && !mainImageName.isEmpty()) {
                mainImagePart.write(uploadDir + File.separator + mainImageName);
                mainImageUrl = savePath + "/" + mainImageName;
            }
        }
        
        for (int i = 1; i <= 4; i++) {
            Part detailImagePart = request.getPart("detail_image" + i);
            if (detailImagePart != null && detailImagePart.getSize() > 0) {
                String detailImageName = getFileName(detailImagePart);
                if (detailImageName != null && !detailImageName.isEmpty()) {
                    detailImagePart.write(uploadDir + File.separator + detailImageName);
                    detailImageUrls.add(savePath + "/" + detailImageName);
                }
            }
        }
        
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false);
        
        String sql1 = "INSERT INTO Product "
                    + "(user_id, category_id, product_name, price, description, main_image_url, shipping_included, is_direct_trade) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        pstmt = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
        
        pstmt.setString(1, userId);
        pstmt.setString(2, categoryId); 
        pstmt.setString(3, productName);
        pstmt.setInt(4, price);
        pstmt.setString(5, description);
        pstmt.setString(6, mainImageUrl);
        pstmt.setBoolean(7, shippingIncluded); 
        pstmt.setBoolean(8, isDirectTrade);
        
        pstmt.executeUpdate();
        
        rs = pstmt.getGeneratedKeys();
        if (rs.next()) {
            generatedProductId = rs.getInt(1);
        } else {
            throw new Exception("Product ID 생성에 실패했습니다.");
        }
        rs.close();
        pstmt.close();

        if (!detailImageUrls.isEmpty()) {
            String sql2 = "INSERT INTO ProductImage (product_id, image_url, display_order) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql2);
            
            for (int i = 0; i < detailImageUrls.size(); i++) {
                pstmt.setInt(1, generatedProductId);
                pstmt.setString(2, detailImageUrls.get(i));
                pstmt.setInt(3, i + 1); 
                pstmt.executeUpdate();
            }
        }
        
        conn.commit();
        
    } catch (Exception e) {
        if (conn != null) { 
            try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } 
        }
        e.printStackTrace();
        errorMessage = e.getMessage().replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
        
    } finally {
        if (conn != null) { 
            try { conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); } 
        }
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignore) {}
        }
        if (pstmt != null) {
            try { pstmt.close(); } catch (SQLException ignore) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignore) {}
        }
    }
    
    if (errorMessage == null) {
        session.setAttribute("toastMessage", "상품이 성공적으로 등록되었습니다.");
        response.sendRedirect("mypage.jsp");
    }
%>
<%
    if (errorMessage != null) {
%>
        <script>
            alert("상품 등록 중 오류가 발생했습니다: <%= errorMessage %>");
            history.back();
        </script>
<%
    }
%>