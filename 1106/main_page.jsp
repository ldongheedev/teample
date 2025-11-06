<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아</title>
    
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }
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
        
        .header-links a {
            margin-left: 20px;
            text-decoration: none;
            color: #555;
            font-size: 14px;
        }
        
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
        
        .swiper {
            width: 100%;
            max-width: 700px; 
            margin: 30px auto 0 auto;
        }
        .swiper-slide img {
            width: 100%;
            height: 300px;
            object-fit: contain;
            background-color: #eee;
        }

        .recommend-section {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .recommend-section h2 {
            font-size: 20px;
            margin-bottom: 20px;
            color: #333;
        }
        
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
    
    <div class="swiper mySwiper">
        <div class="swiper-wrapper">
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/logo.png" alt="이미지1"></div>
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/img2.jpg" alt="이미지2"></div>
            <div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/img3.jpg" alt="이미지3"></div>
        </div>
        <div class="swiper-pagination"></div>
        <div class="swiper-button-prev"></div>
        <div class="swiper-button-next"></div>
    </div>
    <section class="recommend-section">
        <h2>상품 추천</h2>
        <div class="product-grid">
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                boolean hasProducts = false;
                DecimalFormat formatter = new DecimalFormat("#,###"); 

                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                    
                    String sql = "SELECT product_id, product_name, price, main_image_url FROM Product " +
                                 "WHERE is_sold_out = FALSE ORDER BY created_at DESC";
                    
                    pstmt = conn.prepareStatement(sql);
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
                            // 이미지가 /uploads/product/... 와 같이 저장되어 있다고 가정하고 컨텍스트 경로를 앞에 붙임
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
                        out.println("<p>현재 등록된 상품이 없습니다.</p>");
                    }
                    
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p style='color:red;'>상품 목록을 불러오는 중 오류가 발생했습니다.</p>");
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
        const swiper = new Swiper(".mySwiper", {
            loop: true,
            autoplay: {
                delay: 3000,
            },
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            },
            navigation: {
                nextEl: ".swiper-button-next",
                prevEl: ".swiper-button-prev",
            },
        });

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
    </script>

</body>
</html>