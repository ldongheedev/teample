<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.ArrayList" %>

<%
    // 1. 검색어 (query) 파라미터 받기
    String searchQuery = request.getParameter("query");
    
    if (searchQuery == null || searchQuery.trim().isEmpty()) {
        searchQuery = ""; // 빈 검색어로 설정 (DB 쿼리에서 LIKE '%%'가 됨)
    }

    String displaySearchQuery = searchQuery; // 사용자에게 보여줄 검색어
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    DecimalFormat formatter = new DecimalFormat("#,###");

    // 상품 정보를 담을 내부 클래스 정의
    class Product {
        int id;
        String name;
        int price;
        String mainImage;
        String categoryName;
    }
    ArrayList<Product> productList = new ArrayList<>();
    
    // DB에서 검색 결과를 가져오는 로직
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 검색 쿼리: 상품 이름이나 설명에서 검색어를 포함하는 상품을 조회 (LIKE %...%)
        String sql = "SELECT p.product_id, p.product_name, p.price, p.main_image_url, c.category_name " +
                     "FROM Product p " +
                     "JOIN Category c ON p.category_id = c.category_id " +
                     "WHERE p.product_name LIKE ? OR p.product_description LIKE ? " +
                     "ORDER BY p.reg_date DESC";
                     
        pstmt = conn.prepareStatement(sql);
        String searchParam = "%" + searchQuery + "%";
        pstmt.setString(1, searchParam); // product_name 검색 조건
        pstmt.setString(2, searchParam); // product_description 검색 조건
        
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Product p = new Product();
            p.id = rs.getInt("product_id");
            p.name = rs.getString("product_name");
            p.price = rs.getInt("price");
            // 이미지 경로는 'images/upload/'와 같이 저장되었다고 가정
            p.mainImage = rs.getString("main_image_url"); 
            p.categoryName = rs.getString("category_name");
            productList.add(p);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>검색 결과: <%= displaySearchQuery %></title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        h2 { font-size: 28px; font-weight: 700; margin-bottom: 30px; border-bottom: 2px solid #81c147; padding-bottom: 10px; }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 20px;
            padding-bottom: 50px;
        }
        .product-card {
            background-color: #fff; border: 1px solid #eee; border-radius: 8px; overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05); text-decoration: none; color: inherit; transition: transform 0.2s;
        }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 6px 10px rgba(0,0,0,0.1); }
        .product-card img { width: 100%; height: 200px; object-fit: cover; }
        .product-info { padding: 15px; }
        .product-info p { margin: 5px 0; font-size: 14px; }
        .product-info .name { font-weight: 500; font-size: 16px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .product-info .price { font-size: 18px; font-weight: 700; color: #81c147; margin-top: 10px; }
        .no-results { text-align: center; padding: 50px 0; font-size: 18px; color: #777; }
    </style>
</head>
<body>

    <div class="container">
        <h2>'<%= displaySearchQuery %>' 검색 결과 (<%= productList.size() %>건)</h2>
        
        <% if (productList.isEmpty()) { %>
            <div class="no-results">
                검색 결과가 없습니다. 다른 검색어로 시도해 보세요.
            </div>
        <% } else { %>
            <div class="product-grid">
                <% for (Product p : productList) { %>
                    <a href="product_detail.jsp?product_id=<%= p.id %>" class="product-card">
                        <img src="<%= request.getContextPath() %>/<%= p.mainImage %>" alt="<%= p.name %>">
                        <div class="product-info">
                            <p class="name"><%= p.name %></p>
                            <p style="color: #999;">[<%= p.categoryName %>]</p>
                            <p class="price"><%= formatter.format(p.price) %>원</p>
                        </div>
                    </a>
                <% } %>
            </div>
        <% } %>
    </div>
    
    </body>
</html>