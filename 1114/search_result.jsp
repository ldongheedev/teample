<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // URL에서 검색어 (query) 파라미터 받기
    String searchQuery = request.getParameter("query");
    if (searchQuery == null) {
        searchQuery = ""; // 검색어가 없으면 빈 문자열로 처리
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>"<%= searchQuery %>" 검색 결과 - 중고모아</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }
        
        /* --- 1. 헤더 (Header) 스타일 --- */
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
            object-fit: contain; 
        }
        
        .header-links {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .welcome-message {
            font-size: 14px;
            color: #333;
            font-weight: 500;
        }
        
        /* 드롭다운 메뉴 스타일 */
        .dropdown {
            position: relative;
            display: inline-block;
        }
        .dropdown-toggle {
            height: 40px;
            width: 40px;
            cursor: pointer;
            border-radius: 50%;
            object-fit: cover;
        }
        .dropdown-content {
            display: none;
            position: absolute;
            right: 0;
            background-color: #ffffff;
            min-width: 120px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            z-index: 1001;
            border-radius: 5px;
        }
        .dropdown-content a {
            color: #333;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            margin: 0;
            font-size: 14px;
        }
        .dropdown-content a:hover {
            background-color: #f1f1f1;
        }
        .show {
            display: block;
        }
        
        /* --- 2. 검색 영역 및 햄버거 메뉴 (Search Area & Hamburger) 스타일 --- */
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
            margin: 0; 
        }
        .category-nav li a:hover {
            background-color: #f5f5ff;
        }

        /* 검색 바 레이아웃 */
        .search-bar {
            flex-grow: 1;
            display: flex;
            justify-content: center;
        }
        .search-bar form { 
            display: flex;
            width: 100%;
            max-width: 500px; 
            position: relative; 
        }

        /* 💡 검색 입력 필드 (요청된 스타일 적용) */
        .search-bar input[name="query"] {
            flex-grow: 1;
            width: auto;
            padding: 10px 40px 10px 15px; /* X 버튼 공간 확보 */
            border: 2px solid #81c147; 
            border-right: none;
            border-radius: 8px 0 0 8px;
            outline: none;
            font-size: 16px;
            height: 44px; /* 높이 통일 */
            box-sizing: border-box; 
        }
        
        /* X 버튼 스타일 */
        .clear-search {
            position: absolute;
            right: 80px; 
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            cursor: pointer;
            color: #999;
            font-size: 18px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            display: none; 
            z-index: 10;
        }
        
        /* 검색 버튼 스타일 */
        .search-bar button.search-button {
            background-color: #81c147;
            color: white;
            padding: 0 15px; 
            border: none;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.2s;
            border-radius: 0 8px 8px 0;
            height: 44px; 
            line-height: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .search-bar button.search-button:hover {
            background-color: #6a9c3b;
        }

        /* --- 3. 검색 결과 컨텐츠 (Content) 스타일 --- */
        .search-results-section {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .search-results-section h2 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr); 
            gap: 20px;
        }
        .product-card {
            background-color: #fff;
            border: 1px solid #eee;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            overflow: hidden; 
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .product-card a {
            text-decoration: none;
            color: inherit;
        }
        .product-card img {
            width: 100%;
            height: 220px;
            object-fit: contain;
            background-color: #ffffff;
        }
        .product-card .info {
            padding: 15px;
        }
        .product-card .info .name {
            font-size: 16px;
            font-weight: 500;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .product-card .info .price {
            font-size: 15px;
            font-weight: bold;
            color: #333;
            margin-top: 5px;
        }

        /* --- 4. 푸터 (Footer) 스타일 --- */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 40px;
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
        .admin-link {
            font-weight: bold;
            color: #2c7be5; 
            margin-top: 10px;
            display: inline-block;
        }
        .admin-link:hover {
            text-decoration: underline;
        }
    </style>
    
    <script>
        function toggleDropdown() {
            document.getElementById("myDropdown").classList.toggle("show");
        }

        window.onclick = function(event) {
            if (!event.target.matches('.dropdown-toggle')) {
                var dropdowns = document.getElementsByClassName("dropdown-content");
                for (var i = 0; i < dropdowns.length; i++) {
                    var openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) {
                        openDropdown.classList.remove('show');
                    }
                }
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="logo">
            <a href="main_page.jsp">
                <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;">
            </a>
        </div>
        <div class="header-links">
        
            <%
            if ((String)session.getAttribute("userId") == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
                
                <input type="button" value="" onclick="location.href='loginpage.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
            <%
            } else {
            %>
                <div class="welcome-message">
                    <%= (String)session.getAttribute("userName") %>님, 환영합니다.
                </div>
                
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                    </div>
                </div>
                
                <input type="button" value="" onclick="location.href='notifications.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
                
            <%
            }
            %>
        </div>
    </header>
    
    <div class="search-area-container">
        <div style="position: relative;" id="menuArea">
            <button id="hamburger-btn">
                <span></span>
                <span></span>
                <span></span>
            </button>
            <nav class="category-nav" id="category-menu">
                <ul>
                    <li><a href="category_list.jsp?category_id=all">전체 카테고리</a></li>
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
                <input type="text" name="query" id="searchInput" placeholder="새로운 검색어를 입력하세요" value="<%= searchQuery %>" required />
                <span class="clear-search" id="clearSearchBtn">X</span>
                <button type="submit" class="search-button">검색</button> 
            </form>
        </div>
    </div>
    
    <section class="search-results-section">
        <h2>'<%= searchQuery %>' 검색 결과</h2>
        
        <div class="product-grid">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                boolean hasProducts = false;
                DecimalFormat formatter = new DecimalFormat("#,###"); 
                
                // 검색어와 비슷한 상품을 찾기 위한 SQL 쿼리 (모든 카테고리 포함, LIKE 사용)
                String sql = "SELECT product_id, product_name, price, main_image_url FROM Product " +
                             "WHERE is_sold_out = FALSE AND product_name LIKE ? " +
                             "ORDER BY created_at DESC"; 
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                    
                    pstmt = conn.prepareStatement(sql);
                    // LIKE 검색을 위해 '%'를 검색어 앞뒤에 추가
                    pstmt.setString(1, "%" + searchQuery + "%");
                    
                    rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
                        hasProducts = true;
                        int pId = rs.getInt("product_id");
                        String pName = rs.getString("product_name");
                        int pPrice = rs.getInt("price");
                        String pImage = rs.getString("main_image_url");
                        
                        if (pImage == null || pImage.trim().isEmpty()) {
                            pImage = request.getContextPath() + "/images/logo.png";
                        } else {
                            // 이미지가 /uploads/product/... 와 같이 저장되어 있다고 가정
                            pImage = request.getContextPath() + pImage; 
                        }
            %>
                        <div class="product-card">
                            <a href="product_detail.jsp?product_id=<%= pId %>">
                                <img src="<%= pImage %>" alt="<%= pName %>">
                                <div class="info">
                                    <p class="name"><%= pName %></p>
                                    <p class="price"><%= formatter.format(pPrice) %>원</p>
                                </div>
                            </a>
                        </div>
            <%
                    } 
                    
                    if (!hasProducts) {
                        out.println("<p style='grid-column: 1 / -1; padding: 20px; text-align: center; color: #555;'>");
                        out.println("죄송합니다. **'" + searchQuery + "'**와 일치하거나 비슷한 상품이 없습니다.");
                        out.println("</p>");
                    }
                    
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p style='grid-column: 1 / -1; padding: 20px; text-align: center; color:red;'>검색 결과를 불러오는 중 오류가 발생했습니다.</p>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                }
            %>
        </div>
    </section>
    
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
                <a href="company_intro.jsp"> <%= companyIntro %> </a><br>
                <a href="notice_list.jsp"> <%= notice %> </a><br>
            </div>
            <div class="footer-section">
                <h4>SUPPORT</h4>
                <a href="#"> <%= question %> </a><br>
                <a href="#"> <%= faq %> </a>
                
                <%
                    String isAdmin = (String) session.getAttribute("isAdmin");
                    if (isAdmin != null && isAdmin.equals("true")) {
                %>
                    <br>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                <%
                    }
                %>
            </div>
        </div>
    </footer>

    <script>
        // 드롭다운 메뉴 토글
        const menuArea = document.getElementById('menuArea');
        const categoryMenu = document.getElementById('category-menu');

        menuArea.addEventListener('mouseover', function() {
            categoryMenu.classList.add('show');
        });
        menuArea.addEventListener('mouseout', function(e) {
            if (!menuArea.contains(e.relatedTarget)) {
                 categoryMenu.classList.remove('show');
            }
        });

        // 💡 검색창 기능 개선 스크립트 (X 버튼 표시/삭제)
        const searchInput = document.getElementById('searchInput');
        const clearSearchBtn = document.getElementById('clearSearchBtn');
        
        // 1. 페이지 로드 시 검색어가 있으면 X 버튼 표시
        if (searchInput.value.length > 0) {
            clearSearchBtn.style.display = 'block';
        }

        // 2. 입력 내용에 따라 X 버튼 표시/숨기기
        searchInput.addEventListener('input', function() {
            if (this.value.length > 0) {
                clearSearchBtn.style.display = 'block';
            } else {
                clearSearchBtn.style.display = 'none';
            }
        });

        // 3. X 버튼 클릭 시 입력 내용 삭제
        clearSearchBtn.addEventListener('click', function() {
            searchInput.value = '';
            this.style.display = 'none'; 
            searchInput.focus(); 
        });
    </script>

</body>
</html>