<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.DecimalFormat" %>
<%@ page import="util.DBManager" %>

<%
    // ✨ [리팩토링] 메인 페이지용 상품 목록 조회 (DBManager 사용)
    List<Map<String, Object>> productList = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    DecimalFormat formatter = new DecimalFormat("#,###");

    try {
        conn = DBManager.getConnection();
        // 최신순으로 판매되지 않은 상품 8개만 추천
        String sql = "SELECT product_id, product_name, price, main_image_url FROM Product " +
                     "WHERE is_sold_out = FALSE ORDER BY created_at DESC LIMIT 8";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", rs.getInt("product_id"));
            map.put("name", rs.getString("product_name"));
            map.put("price", rs.getInt("price"));
            
            String img = rs.getString("main_image_url");
            if (img == null || img.trim().isEmpty()) {
                img = request.getContextPath() + "/images/logo.png";
            } else {
                // 이미지가 /uploads/product/... 와 같이 저장되어 있다고 가정
                img = request.getContextPath() + img;
            }
            map.put("image", img);
            productList.add(map);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DBManager.close(conn, pstmt, rs);
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아</title>
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        
        /* 검색 영역 스타일 */
        .search-area-container { margin: 30px 0 0 0; padding: 0 40px; position: relative; display: flex; align-items: flex-start; gap: 20px; }
        #hamburger-btn { background: none; border: none; cursor: pointer; padding: 0; display: flex; flex-direction: column; justify-content: space-around; width: 24px; height: 24px; }
        #hamburger-btn span { display: block; width: 100%; height: 3px; background-color: #333; border-radius: 3px; }
        
        .category-nav { position: absolute; top: 30px; left: -10px; width: 200px; background-color: #fff; box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 1000; opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0.3s ease; }
        .category-nav.show { opacity: 1; visibility: visible; }
        .category-nav ul { list-style: none; margin: 0; padding: 10px; }
        .category-nav li a { display: block; padding: 8px 10px; text-decoration: none; color: #333; font-size: 15px; margin: 0; }
        .category-nav li a:hover { background-color: #f5f5f5; }

        .search-bar { flex-grow: 1; display: flex; justify-content: center; }
        .search-bar form { display: flex; width: 100%; max-width: 500px; position: relative; }
        .search-bar input[name="query"] { flex-grow: 1; width: auto; padding: 10px 40px 10px 15px; border: 2px solid #81c147; border-right: none; border-radius: 8px 0 0 8px; outline: none; font-size: 16px; height: 44px; box-sizing: border-box; }
        .clear-search { position: absolute; right: 80px; top: 50%; transform: translateY(-50%); width: 20px; height: 20px; cursor: pointer; color: #999; font-size: 18px; font-weight: bold; line-height: 20px; text-align: center; display: none; z-index: 10; }
        .search-bar button.search-button { background-color: #81c147; color: white; padding: 0 15px; border: none; cursor: pointer; font-size: 16px; font-weight: 500; transition: background-color 0.2s; border-radius: 0 8px 8px 0; height: 44px; line-height: 1; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .search-bar button.search-button:hover { background-color: #6a9c3b; }

        /* 배너 스타일 */
        .swiper { width: 100%; max-width: 900px; margin: 30px auto 0 auto; }
        .swiper-slide img { width: 100%; height: 290px; object-fit: contain; background-color: #eee; }

        /* 추천 상품 섹션 */
        .recommend-section { max-width: 1200px; margin: 40px auto; padding: 0 20px; }
        .recommend-section h2 { font-size: 20px; margin-bottom: 20px; color: #333; }
        .product-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .product-card { background-color: #fff; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); overflow: hidden; transition: transform 0.2s, box-shadow 0.2s; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .product-card a { text-decoration: none; color: inherit; }
        .product-card img { width: 100%; height: 220px; object-fit: contain; background-color: #ffffff; }
        .product-card .info { padding: 15px; }
        .product-card .info .name { font-size: 16px; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .product-card .info .price { font-size: 15px; font-weight: bold; color: #333; margin-top: 5px; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    
    <div class="search-area-container">
        <div style="position: relative;" id="menuArea">
            <button id="hamburger-btn">
                <span></span><span></span><span></span>
            </button>
            <nav class="category-nav" id="category-menu">
                <ul>
                    <li><a href="#" onclick="return false;">전체 카테고리</a></li>
                    <li><a href="category_list.jsp?category_id=clothing">의류</a></li>
                    <li><a href="category_list.jsp?category_id=food">식품</a></li>
                    <li><a href="category_list.jsp?category_id=accessory">액세서리</a></li>
                    <li><a href="category_list.jsp?category_id=digital">디지털/가전제품</a></li>
                    <li><a href="category_list.jsp?category_id=sports">스포츠 용품</a></li>
                    <li><a href="category_list.jsp?category_id=pet">애완동물 용품</a></li>
                    <li><a href="category_list.jsp?category_id=talent">재능</a></li>
                </ul>
            </nav>
        </div>

        <div class="search-bar">
            <form action="search_result.jsp" method="get" class="search-form" id="searchForm">
                <input type="text" name="query" id="searchInput" placeholder="상품명, 카테고리 등을 검색해보세요" required />
                <span class="clear-search" id="clearSearchBtn">X</span>
                <button type="submit" class="search-button">검색</button> 
            </form>
        </div>
    </div>
    
    <div class="swiper mySwiper">
        <div class="swiper-wrapper">
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/logo.png" alt="이미지1"></div>
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/banner1.png" alt="이미지2"></div>
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/banner2.png" alt="이미지3"></div>
        </div>
        <div class="swiper-pagination"></div>
        <div class="swiper-button-prev"></div>
        <div class="swiper-button-next"></div>
    </div>

    <section class="recommend-section">
        <h2>상품 추천</h2>
        <div class="product-grid">
            <%
                if (productList.isEmpty()) {
                    out.println("<p style='grid-column: 1 / -1; text-align: center; padding: 20px; color: #777;'>현재 등록된 상품이 없습니다.</p>");
                } else {
                    for (Map<String, Object> p : productList) {
            %>
                        <div class="product-card">
                            <a href="product_detail.jsp?product_id=<%= p.get("id") %>">
                                <img src="<%= p.get("image") %>" alt="<%= p.get("name") %>">
                                <div class="info">
                                    <p class="name"><%= p.get("name") %></p>
                                    <p class="price"><%= formatter.format(p.get("price")) %>원</p>
                                </div>
                            </a>
                        </div>
            <%
                    }
                }
            %>
        </div>
    </section>
    
    <jsp:include page="footer.jsp" />

    <script>
        const swiper = new Swiper(".mySwiper", {
            loop: true,
            autoplay: { delay: 3000 },
            pagination: { el: ".swiper-pagination", clickable: true },
            navigation: { nextEl: ".swiper-button-next", prevEl: ".swiper-button-prev" },
        });

        // 카테고리 메뉴
        const menuArea = document.getElementById('menuArea');
        const categoryMenu = document.getElementById('category-menu');
        menuArea.addEventListener('mouseover', function() { categoryMenu.classList.add('show'); });
        menuArea.addEventListener('mouseout', function(e) { if (!menuArea.contains(e.relatedTarget)) categoryMenu.classList.remove('show'); });

        // 검색창 X 버튼
        const searchInput = document.getElementById('searchInput');
        const clearSearchBtn = document.getElementById('clearSearchBtn');
        searchInput.addEventListener('input', function() {
            clearSearchBtn.style.display = (this.value.length > 0) ? 'block' : 'none';
        });
        clearSearchBtn.addEventListener('click', function() {
            searchInput.value = '';
            this.style.display = 'none';
            searchInput.focus();
        });
        
        // 토스트 메시지 확인 (로그아웃 등 처리 후 메시지)
        <%
            String toastMsg = (String) session.getAttribute("toastMessage");
            if (toastMsg != null) {
                session.removeAttribute("toastMessage");
        %>
            alert("<%= toastMsg %>");
        <%
            }
        %>
    </script>
</body>
</html>