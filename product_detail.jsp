<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %> 
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%-- 
  1. 상품 상세 페이지 로직 (HTML 렌더링 전 데이터 조회)
--%>
<%
    request.setCharacterEncoding("UTF-8");
    NumberFormat numberFormat = NumberFormat.getInstance(Locale.KOREA);

    // URL에서 product_id 받기
    String productId = request.getParameter("product_id");

    if (productId == null || productId.isEmpty()) {
        response.sendRedirect("main.jsp");
        return;
    }

    // DB 조회 결과를 담을 변수 선언
    String categoryName = "";
    String productName = "";
    int price = 0;
    String description = "";
    String mainImageUrl = "";
    boolean isSoldOut = false;
    String productCategoryId = ""; // 관련 상품 조회를 위한 카테고리 ID

    // 상세 이미지 목록 (ProductImage 테이블)
    List<String> detailImageUrls = new ArrayList<>();
    
    // 관련 상품 목록 (이 상품과 비슷해요)
    class RelatedProduct {
        String id;
        String name;
        String imageUrl;
        public RelatedProduct(String id, String name, String url) {
            this.id = id; this.name = name; this.imageUrl = url;
        }
    }
    List<RelatedProduct> relatedProducts = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        // --- 1. 메인 상품 정보 조회 (Product + Category Join) ---
        String sql = "SELECT p.product_name, p.price, p.description, p.main_image_url, p.is_sold_out, c.category_name, c.category_id " +
                     "FROM Product p " +
                     "JOIN Category c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(productId));
        rs = pstmt.executeQuery();

        if (rs.next()) {
            productName = rs.getString("product_name");
            price = rs.getInt("price");
            description = rs.getString("description");
            mainImageUrl = rs.getString("main_image_url");
            isSoldOut = rs.getBoolean("is_sold_out");
            categoryName = rs.getString("category_name");
            productCategoryId = rs.getString("category_id");
        } else {
            // 상품이 없는 경우
            out.println("<script>alert('존재하지 않는 상품입니다.'); location.href='main.jsp';</script>");
            return;
        }
        
        rs.close();
        pstmt.close();

        // --- 2. 상세 이미지 목록 조회 (ProductImage) ---
        sql = "SELECT image_url FROM ProductImage WHERE product_id = ? ORDER BY display_order ASC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(productId));
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            detailImageUrls.add(rs.getString("image_url"));
        }

        rs.close();
        pstmt.close();
        
        // --- 3. 관련 상품 조회 (이 상품과 비슷해요) ---
        sql = "SELECT product_id, product_name, main_image_url FROM Product " +
              "WHERE category_id = ? AND product_id != ? " +
              "ORDER BY created_at DESC LIMIT 3";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, productCategoryId);
        pstmt.setInt(2, Integer.parseInt(productId));
        rs = pstmt.executeQuery();

        while(rs.next()) {
            relatedProducts.add(new RelatedProduct(
                rs.getString("product_id"),
                rs.getString("product_name"),
                rs.getString("main_image_url")
            ));
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>DB 오류 발생: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* 무시 */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* 무시 */ }
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* 무시 */ }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= productName %> - 중고모아</title>
    
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <style>
        /* 1. 고정 스타일 (main.jsp와 동일) 
        */
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; }
        .header-links input { margin-left: 20px; }
        .search-area-container { margin: 30px 0 0 0; padding: 0 40px; position: relative; display: flex; align-items: flex-start; gap: 20px; }
        #hamburger-btn { background: none; border: none; cursor: pointer; padding: 0; display: flex; flex-direction: column; justify-content: space-around; width: 24px; height: 24px; }
        #hamburger-btn span { display: block; width: 100%; height: 3px; background-color: #333; border-radius: 3px; }
        .category-nav { position: absolute; top: 30px; left: -10px; width: 200px; background-color: #fff; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0.3s ease; }
        .category-nav.show { opacity: 1; visibility: visible; }
        .category-nav ul { list-style: none; margin: 0; padding: 10px; }
        .category-nav li a { display: block; padding: 8px 10px; text-decoration: none; color: #333; font-size: 15px; }
        .category-nav li a:hover { background-color: #f5f5f5; }
        .search-bar { flex-grow: 1; display: flex; justify-content: center; }
        .search-input-wrapper { position: relative; width: 100%; max-width: 500px; }
        .search-bar input { width: 100%; padding: 12px 16px; border: 1px solid #ccc; border-radius: 8px; font-size: 16px; }
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }

        /* 2. 상품 상세 페이지 고유 스타일 
        */
        .content-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px 40px;
        }

        .category-header {
            font-size: 24px;
            font-weight: bold;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 30px;
        }

        .product-main-content {
            display: flex;
            gap: 40px;
            margin-bottom: 40px;
        }

        .product-image-section {
            flex: 1;
        }
        
        .product-image-section img {
            width: 100%;
            height: auto;
            aspect-ratio: 1 / 1; /* 1:1 비율 */
            object-fit: cover;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        .product-info-section {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .product-name {
            font-size: 28px;
            font-weight: bold;
            margin: 0 0 10px 0;
        }
        
        .product-price {
            font-size: 32px;
            font-weight: bold;
            color: #ff5722;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 20px;
        }

        .product-shipping-info {
            font-size: 16px;
            color: #555;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        /* 버튼 스타일 */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .btn {
            padding: 15px;
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            border-radius: 8px;
            border: 1px solid #000;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-buy {
            background-color: #333;
            color: #fff;
        }
        
        .btn-group {
            display: flex;
            gap: 10px;
        }

        .btn-cart, .btn-wish {
            flex: 1;
            background-color: #fff;
            color: #333;
        }
        
        /* 관련 상품 스타일 */
        .related-products-section {
            margin-bottom: 40px;
        }
        
        .related-products-section h3 {
            font-size: 18px;
            margin-bottom: 15px;
        }
        
        .related-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
        }
        
        .related-card {
            border: 1px solid #eee;
            border-radius: 8px;
            background: #fff;
            text-decoration: none;
            color: #333;
            overflow: hidden;
        }
        
        .related-card img {
            width: 100%;
            height: 150px;
            object-fit: cover;
        }

        .related-card-info {
            padding: 10px;
            font-size: 14px;
            text-align: center;
        }

        /* 탭 스타일 */
        .tab-container {
            display: flex;
            border-bottom: 2px solid #ccc;
            margin-bottom: 20px;
        }
        
        .tab {
            padding: 10px 20px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            border: 1px solid #ccc;
            border-bottom: none;
            background-color: #f1f1f1;
            margin-right: 5px;
            border-radius: 8px 8px 0 0;
        }
        
        .tab.active {
            background-color: #fff;
            border-bottom: 2px solid #fff; /* 하단 테두리를 흰색으로 덮어씌움 */
            position: relative;
            top: 2px;
        }
        
        .tab-content {
            display: none; /* 기본적으로 숨김 */
            padding: 20px;
            border: 1px solid #ccc;
            border-top: none;
            background: #fff;
            min-height: 200px;
        }
        
        .tab-content.active {
            display: block; /* 활성화된 탭만 보임 */
        }
        
        .tab-content img {
            max-width: 100%;
            height: auto;
            margin: 10px 0;
        }
    </style>
</head>
<body>

<%-- 
  2. 고정 상단 (main.jsp와 동일)
--%>
<header>
    <div class="logo">
        <a href="main_page.jsp">
            <img src="<%= request.getContextPath() %>/images/logo.png" style="max-height: 60px; object-fit: contain;">
        </a>
    </div>
    <div class="header-links">
        <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
        <input type="button" value="내상점" onclick="location.href='mystore.jsp'" >
        <input type="button" value="" onclick="location.href='loginpage.jsp'"
            style="background: url('<%= request.getContextPath() %>/images/bell.png');
                   background-size: contain;
                   width: 35px; height: 35px; border: none;" />
    </div>
</header>

<div class="search-area-container">
    <div style="position: relative;">
        <button id="hamburger-btn">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <nav class="category-nav" id="category-menu">
            <ul>
                <li><a href="category_list.jsp?category=all">전체 카테고리</a></li>
                <li><a href="category_list.jsp?category=clothing">의류</a></li>
                <li><a href="category_list.jsp?category=food">식품</a></li>
                <li><a href="category_list.jsp?category=accessories">액세서리</a></li>
                <li><a href="category_list.jsp?category=digital">디지털/가전제품</a></li>
                <li><a href="category_list.jsp?category=sports">스포츠 용품</a></li>
                <li><a href="category_list.jsp?category=pet">애완동물용품</a></li>
                <li><a href="category_list.jsp?category=talent">재능</a></li>
            </ul>
        </nav>
    </div>

    <div class="search-bar">
        <div class="search-input-wrapper">
            <input type="text" id="searchInput" placeholder="검색어를 입력하세요" />
            <button type="button"
                onclick="document.getElementById('searchInput').value=''"
                style="position: absolute; right: 5px; top: 50%; transform: translateY(-50%); background: none; border: none; font-size: 16px; cursor: pointer; padding: 0; line-height: 1;"
                aria-label="지우기">✕</button>
        </div>
    </div>
</div>

<%-- 
  3. 상품 상세 페이지 컨텐츠 
--%>
<div class="content-container">

    <div class="category-header">
        <%= categoryName %>
    </div>

    <div class="product-main-content">
        
        <div class="product-image-section">
            <img src="<%= request.getContextPath() %><%= mainImageUrl %>" alt="<%= productName %> 대표 이미지">
        </div>

        <div class="product-info-section">
            
            <h2 class="product-name"><%= productName %></h2>
            <div class="product-price"><%= numberFormat.format(price) %>원</div>
            
            <div class="product-shipping-info">
                상품상태 : <%= isSoldOut ? "<span style='color:red; font-weight:bold;'>품절</span>" : "판매중" %>
                <br>
                택배비 포함 여부 : O / X (DB 스키마에 추가 필요)
            </div>
            
            <div class="action-buttons">
                <a href="#" class="btn btn-buy">바로 구매</a>
                <div class="btn-group">
                    <a href="#" class="btn btn-cart">장바구니</a>
                    <a href="#" class="btn btn-wish">찜하기</a>
                </div>
            </div>
            
        </div>
    </div>

    <div class="related-products-section">
        <h3>이 상품과 비슷해요</h3>
        <div class="related-grid">
            <% for (RelatedProduct p : relatedProducts) { %>
                <a href="product_detail.jsp?product_id=<%= p.id %>" class="related-card">
                    <img src="<%= request.getContextPath() %><%= p.imageUrl %>" alt="<%= p.name %>">
                    <div class="related-card-info">
                        <%= p.name %>
                    </div>
                </a>
            <% } %>
            <%-- 관련 상품이 3개 미만일 경우 빈 칸으로 남음 --%>
        </div>
    </div>

    <div class="tab-container">
        <div class="tab active" onclick="showTab('info')">상품 정보</div>
        <div class="tab" onclick="showTab('map')">지도</div>
    </div>
    
    <div id="tab-info" class="tab-content active">
        <p><%= description.replace("\n", "<br>") %></p>
        
        <%-- 상세 이미지 목록 (ProductImage 테이블) --%>
        <% for (String imgUrl : detailImageUrls) { %>
            <img src="<%= request.getContextPath() %><%= imgUrl %>" alt="상세 이미지">
        <% } %>
    </div>
    
    <div id="tab-map" class="tab-content">
        <p>지도 정보가 여기에 표시됩니다. (예: 카카오맵 API 연동)</p>
        </div>

</div>

<%-- 
  4. 고정 하단 (main.jsp와 동일)
--%>
<footer>
    <div class="footer-section">
        <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;" />
        <p>(주) 중고모아 | 대표 김령균</p>
        <p>TEL : 010-0000-0000</p>
        <p>Mail : junggomoa@gmail.com</p>
        <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
        <p>이용약관 / 개인정보처리방침</p>
    </div>
    <%
        String companyIntro = "회사소개";
        String notice = "공지사항";
        String question = "1:1 문의";
        String faq = "FAQ";
    %>
    <div style="display: flex; gap: 40px;">
        <div class="footer-section">
            <h4>ABOUT</h4>
            <a href="#"> <%= companyIntro %> </a><br>
            <a href="#"> <%= notice %> </a><br>
        </div>
        <div class="footer-section">
            <h4>SUPPORT</h4>
            <a href="#"> <%= question %> </a><br>
            <a href="#"> <%= faq %> </a>
        </div>
    </div>
</footer>

<%-- 
  5. JavaScript (햄버거 메뉴 + 탭 기능)
--%>
<script>
    // 햄버거 메뉴 스크립트 (main.jsp와 동일)
    const hamburgerBtn = document.getElementById('hamburger-btn');
    const categoryMenu = document.getElementById('category-menu');
    const menuArea = hamburgerBtn.parentNode; 

    menuArea.addEventListener('mouseover', function() {
        categoryMenu.classList.add('show');
    });

    menuArea.addEventListener('mouseout', function(e) {
        if (!menuArea.contains(e.relatedTarget)) {
             categoryMenu.classList.remove('show');
        }
    });

    // 탭 기능 스크립트
    function showTab(tabId) {
        // 모든 탭 컨텐츠 숨기기
        const tabContents = document.querySelectorAll('.tab-content');
        tabContents.forEach(content => {
            content.classList.remove('active');
        });

        // 모든 탭 비활성화
        const tabs = document.querySelectorAll('.tab');
        tabs.forEach(tab => {
            tab.classList.remove('active');
        });

        // 선택된 탭과 컨텐츠 활성화
        document.getElementById('tab-' + tabId).classList.add('active');
        document.querySelector(`.tab[onclick="showTab('${tabId}')"]`).classList.add('active');
    }
</script>

</body>
</html>