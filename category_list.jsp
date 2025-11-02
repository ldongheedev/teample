<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %> 
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%
    request.setCharacterEncoding("UTF-8");
    NumberFormat numberFormat = NumberFormat.getInstance(Locale.KOREA);

    // URL에서 'category' 매개변수 값을 가져옵니다.
    String categoryCode = request.getParameter("category");
    
    // 카테고리 코드에 따른 표시 이름과 DB WHERE 절 설정
    String categoryName = "전체 상품";
    String whereClause = ""; 

    if (categoryCode != null) {
        switch (categoryCode) {
            case "all":
                categoryName = "전체 상품";
                break;
            case "clothing":
                categoryName = "의류";
                whereClause = "WHERE category = 'clothing'";
                break;
            case "food":
                categoryName = "식품";
                whereClause = "WHERE category = 'food'";
                break;
            case "accessories":
                categoryName = "액세서리";
                whereClause = "WHERE category = 'accessories'";
                break;
            case "digital":
                categoryName = "디지털/가전제품";
                whereClause = "WHERE category = 'digital'";
                break;
            case "sports":
                categoryName = "스포츠 용품";
                whereClause = "WHERE category = 'sports'";
                break;
            case "pet":
                categoryName = "애완동물용품";
                whereClause = "WHERE category = 'pet'";
                break;
            case "talent":
                categoryName = "재능";
                whereClause = "WHERE category = 'talent'";
                break;
            default:
                categoryName = "기타 상품";
                whereClause = "WHERE category = '" + categoryCode + "'";
                break;
        }
    }
    
    // 로그인 세션에서 사용자 이름 가져오기 (member 테이블의 nickname 사용)
    String userName = (String) session.getAttribute("userName");
    
    // 임시 상품 정보 클래스 (DB 결과 저장을 위해)
    class Product {
        String id;
        String name;
        int price;
        String imageUrl;
        public Product(String id, String name, int price, String url) {
            this.id = id; this.name = name; this.price = price; this.imageUrl = url;
        }
    }
    List<Product> productList = new ArrayList<>();
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        stmt = conn.createStatement();
        
        // 상품 조회 쿼리: 선택된 카테고리 조건 적용
        String sql = "SELECT product_id, product_name, price, image_url FROM product " + whereClause + " ORDER BY product_id DESC";
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            productList.add(new Product(
                rs.getString("product_id"),
                rs.getString("product_name"),
                rs.getInt("price"),
                rs.getString("image_url")
            ));
        }

    } catch (Exception e) {
        // DB 오류 발생 시 빈 목록 유지
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* 무시 */ }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { /* 무시 */ }
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* 무시 */ }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= categoryName %> 추천 상품 목록</title>
    
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <style>
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }
        /* MAIN JSP HEADER STYLES */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 40px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .logo img {
            height: 60px;
            width: 200px;
        }
        .header-links input {
            margin-left: 20px;
        }

        .search-area-container {
            margin: 30px 0 0 0;
            padding: 0 40px;
            position: relative;
            display: flex;
            align-items: flex-start;
            gap: 20px;
        }

        #hamburger-btn {
            background: none;
            border: none;
            cursor: pointer;
            padding: 0;
            display: flex;
            flex-direction: column;
            justify-content: space-around;
            width: 24px;
            height: 24px;
        }

        #hamburger-btn span {
            display: block;
            width: 100%;
            height: 3px;
            background-color: #333;
            border-radius: 3px;
        }

        /* 마우스 오버 드롭다운 메뉴 관련 CSS */
        .category-nav {
            position: absolute;
            top: 30px; 
            left: -10px; 
            width: 200px;
            background-color: #fff;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease, visibility 0.3s ease;
        }

        .category-nav.show {
            opacity: 1;
            visibility: visible;
        }

        .category-nav ul {
            list-style: none;
            margin: 0;
            padding: 10px;
        }

        .category-nav li a {
            display: block;
            padding: 8px 10px; 
            text-decoration: none;
            color: #333;
            font-size: 15px;
        }

        .category-nav li a:hover {
            background-color: #f5f5f5;
        }

        .search-bar {
            flex-grow: 1;
            display: flex;
            justify-content: center;
        }

        .search-input-wrapper {
            position: relative;
            width: 100%;
            max-width: 500px;
        }

        .search-bar input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
        }
        
        /* CONTENT STYLES (CATEGORY LIST) */
        .category-header {
            max-width: 1200px;
            margin: 40px auto 20px;
            padding: 0 40px;
            font-size: 24px;
            font-weight: bold;
        }
        
        .product-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr); /* 4열 */
            gap: 20px;
            max-width: 1200px;
            margin: 20px auto 40px;
            padding: 0 40px;
        }

        .product-card {
            background-color: #fff;
            border: 1px solid #eee;
            border-radius: 8px;
            display: flex;
            flex-direction: column; 
            justify-content: flex-start;
            align-items: flex-start; 
            overflow: hidden; 
            text-decoration: none;
            color: inherit; 
            min-height: 250px; 
        }

        .product-card-image-wrapper {
            width: 100%; 
            height: 180px; 
            overflow: hidden; 
            border-radius: 8px 8px 0 0;
        }
        
        .product-card-image-wrapper img {
            width: 100%; 
            height: 100%; 
            object-fit: cover; 
        }
        
        .product-card-info {
            padding: 10px; 
            width: 100%; 
            box-sizing: border-box; 
            font-size: 14px; 
            color: #333;
            flex-grow: 1; 
        }
        
        .product-card-info p { margin: 0; }
        
        .product-name {
             margin-bottom: 5px !important; 
             font-weight: bold; 
             white-space: nowrap; 
             overflow: hidden; 
             text-overflow: ellipsis;
        }
        
        .product-price { color: #ff5722; font-weight: bold; }

        /* FOOTER STYLES */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
        }

        .footer-section h4 {
            margin-bottom: 10px;
            font-weight: bold;
        }

        .footer-section p,
        .footer-section a {
            margin: 4px 0;
            text-decoration: none;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <div class="logo">
        <a href="main_page.jsp">
            <img src="<%= request.getContextPath() %>/images/logo.png" style="max-height: 60px; object-fit: contain;">
        </a>
    </div>
    <div class="header-links">
        <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
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
                style="
                    position: absolute;
                    right: 5px;
                    top: 50%;
                    transform: translateY(-50%);
                    background: none;
                    border: none;
                    font-size: 16px;
                    cursor: pointer;
                    padding: 0;
                    line-height: 1;
                "
                aria-label="지우기">✕</button>
        </div>
    </div>
</div>

<%-- 카테고리 헤더: "디지털/가전제품 추천 상품" --%>
<div class="category-header">
    <%= categoryName %> 추천 상품
</div>

<%-- 상품 그리드 영역 (DB 조회 결과 출력) --%>
<div class="product-grid">
    
    <%-- 1. 실제 DB에서 가져온 상품 출력 --%>
    <% for (Product p : productList) { %>
        <a href="product_detail.jsp?product_id=<%= p.id %>" class="product-card">
            <div class="product-card-image-wrapper">
                <img src="<%= request.getContextPath() %><%= p.imageUrl %>" alt="<%= p.name %> 이미지">
            </div>
            <div class="product-card-info">
                <p class="product-name"><%= p.name %></p>
                <p class="product-price"><%= numberFormat.format(p.price) %>원</p>
            </div>
        </a>
    <% } %>
    
    <%-- 2. DB 상품 수에 상관없이 레이아웃 유지를 위한 빈 상품 채우기 (최대 16개) --%>
    <%
    int totalSlots = 16; 
    int currentCount = productList.size();
    
    if (currentCount < totalSlots) {
        for (int i = 0; i < totalSlots - currentCount; i++) {
    %>
            <a href="product_detail.jsp" 
               class="product-card" 
               style="justify-content: center; align-items: center; height: 250px; text-align: center; color: #aaa; background-color: #f9f9f9; text-decoration: none; cursor: pointer;">
                
                <%= categoryName %><br>
                추천 상품<br>
                이미지
            </a>
    <%
        }
    }
    %>
    
</div>

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

<%-- JavaScript: 마우스 오버 메뉴 토글 --%>
<script>
    const hamburgerBtn = document.getElementById('hamburger-btn');
    const categoryMenu = document.getElementById('category-menu');
    // 햄버거 버튼과 카테고리 메뉴를 감싸는 부모 div
    const menuArea = hamburgerBtn.parentNode; 

    // 마우스 오버 시 메뉴 표시
    menuArea.addEventListener('mouseover', function() {
        categoryMenu.classList.add('show');
    });

    // 마우스 아웃 시 메뉴 숨김
    menuArea.addEventListener('mouseout', function(e) {
        if (!menuArea.contains(e.relatedTarget)) {
             categoryMenu.classList.remove('show');
        }
    });
</script>

</body>
</html>