<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="jakarta.servlet.http.Part" %> <%-- 톰캣 10+ (jakarta) --%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%-- ✨ 1. (오류 수정) 파일 업로드 처리를 위한 @multipart-config 선언 추가 --%>

<%!
    // ✨ 2. (유틸리티) Part에서 실제 파일 이름을 추출하는 메서드
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

    // ✨ 3. (오류 수정) 텍스트 필드(Part)를 String으로 변환하는 헬퍼 메서드
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
    // (보안) 로그인 상태 확인
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("loginpage.jsp");
        return;
    }

    // (파일 업로드 설정)
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

    try {
        // ✨ 4. (데이터 추출) request.getPart()로 텍스트/파일 데이터 받기
        request.setCharacterEncoding("UTF-8"); 
        
        String categoryId = partToString(request.getPart("category_id"));
        String productName = partToString(request.getPart("product_name"));
        String priceStr = partToString(request.getPart("price"));
        String description = partToString(request.getPart("description"));
        String shippingStr = partToString(request.getPart("shipping_included"));

        // (데이터 변환)
        int price = (priceStr != null && !priceStr.isEmpty()) ? Integer.parseInt(priceStr) : 0;
        boolean shippingIncluded = "true".equals(shippingStr); 
        
        // (파일 추출)
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
        
        // (DB 연결 및 트랜잭션 시작)
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); 
        
        // (1차 INSERT) Product 테이블
        String sql1 = "INSERT INTO Product (user_id, category_id, product_name, price, description, main_image_url, shipping_included) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        pstmt = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
        pstmt.setString(1, userId);
        pstmt.setString(2, categoryId); 
        pstmt.setString(3, productName);
        pstmt.setInt(4, price);
        pstmt.setString(5, description);
        pstmt.setString(6, mainImageUrl);
        pstmt.setBoolean(7, shippingIncluded); 
        pstmt.executeUpdate();
        
        // (product_id 가져오기)
        rs = pstmt.getGeneratedKeys();
        if (rs.next()) {
            generatedProductId = rs.getInt(1);
        } else {
            throw new Exception("Product ID 생성에 실패했습니다.");
        }
        rs.close();
        pstmt.close();
        
        // (2차 INSERT) ProductImage 테이블
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
        
        conn.commit(); // (성공) 트랜잭션 커밋
        response.sendRedirect("mypage.jsp"); // 마이페이지로 이동

    } catch (Exception e) {
        if (conn != null) { try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } }
        e.printStackTrace();
%>
        <script>
            alert("상품 등록 중 오류가 발생했습니다: <%= e.getMessage().replace("'", "\\'") %>");
            history.back();
        </script>
<%
    } finally {
        // (마무리) 자원 반납
        if (conn != null) { try { conn.setAutoCommit(true); } catch (SQLException se) { se.printStackTrace(); } }
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>