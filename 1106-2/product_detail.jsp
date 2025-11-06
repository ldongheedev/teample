<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.DecimalFormat" %> <%-- 가격 콤마 표시 --%>

<%
    // 1. URL에서 product_id 가져오기
    String productIdStr = request.getParameter("product_id");
    if (productIdStr == null) {
        out.println("<script>alert('상품 ID가 없습니다.'); history.back();</script>");
        return;
    }
    
    int productId = Integer.parseInt(productIdStr);

    // DB 연동 (상품 정보, 이미지, 판매자 닉네임, 카테고리명 조회)
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String pName = "", pDesc = "", pMainImg = "", pCategory = "", pSellerNick = "";
    int pPrice = 0;
    boolean pShippingIncluded = false;
    ArrayList<String> detailImages = new ArrayList<>();
    String pSellerId = null; 

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        // 2. 메인 상품 정보 + 판매자 닉네임/ID + 카테고리명 조회
        String sql = "SELECT p.*, m.nickname, c.category_name " +
                     "FROM Product p " +
                     "JOIN member m ON p.user_id = m.id " +
                     "JOIN category c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ? AND p.is_sold_out = FALSE";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            pName = rs.getString("product_name");
            pPrice = rs.getInt("price");
            pDesc = rs.getString("description");
            pMainImg = rs.getString("main_image_url");
            pShippingIncluded = rs.getBoolean("shipping_included");
            pSellerNick = rs.getString("nickname");
            pCategory = rs.getString("category_name");
            pSellerId = rs.getString("user_id"); 
        } else {
            out.println("<script>alert('존재하지 않거나 판매 완료된 상품입니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        // 3. 상세 이미지 목록(ProductImage) 조회
        String sqlImg = "SELECT image_url FROM ProductImage WHERE product_id = ? ORDER BY display_order ASC";
        pstmt = conn.prepareStatement(sqlImg);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();
        while(rs.next()) {
            detailImages.add(rs.getString("image_url"));
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
    <title>중고모아 - <%= pName %></title>
    
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

        /* --- 헤더 스타일 --- */
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

        /* --- 상품 상세 페이지 CSS --- */
        .detail-wrapper {
            max-width: 1200px;
            margin: 20px auto;
            display: flex;
            gap: 30px;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        
        /* (왼쪽) 이미지 영역 */
        .detail-image-section {
            width: 50%;
            flex-shrink: 0;
            /* ✨ (수정) Swiper가 들어갈 수 있도록 높이 고정 해제 */
        }
        
        /* ✨ (신규) Swiper 스타일 */
        .detail-image-section .swiper {
            width: 100%;
            height: 450px;
            border-radius: 8px;
            background-color: #eee;
        }
        .detail-image-section .swiper-slide {
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .detail-image-section .swiper-slide img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain; /* 이미지가 잘리지 않게 함 */
        }
        /* (Swiper 기본 네비게이션/페이징 버튼 색상) */
        :root {
            --swiper-navigation-color: #333;
            --swiper-pagination-color: #333;
        }

        /* (오른쪽) 정보 영역 */
        .detail-info-section {
            width: 50%;
            display: flex;
            flex-direction: column;
        }
        
        .detail-info-section .category {
            font-size: 14px;
            color: #888;
            font-weight: 500;
        }
        .detail-info-section .title {
            font-size: 28px;
            font-weight: 700;
            color: #333;
            margin: 10px 0;
        }
        .detail-info-section .price {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin-bottom: 20px;
        }
        .detail-info-section .seller-info,
        .detail-info-section .shipping-info {
            font-size: 16px;
            color: #555;
            padding: 15px 0;
            border-top: 1px solid #eee;
        }
        .detail-info-section .shipping-info .shipping-tag {
            font-weight: 500;
            color: #2c7be5; /* 파란색 강조 */
        }
        .detail-info-section .seller-info {
            border-bottom: 1px solid #eee;
        }
        
        /* '바로구매', '찜하기' 버튼 */
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: auto; 
            padding-top: 20px;
        }
        .action-buttons .action-btn {
            flex-grow: 1;
            padding: 15px;
            font-size: 18px;
            font-weight: bold;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
        }
        .action-buttons .btn-wishlist {
            background-color: #a0a0a0;
            color: white;
        }
        .action-buttons .btn-buy {
            background-color: #81c147;
            color: white;
        }

        /* '상품정보', '지도' 탭 */
        .detail-content-wrapper {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            overflow: hidden; 
        }
        .detail-tabs {
            display: flex;
            border-bottom: 2px solid #ccc;
        }
        .detail-tabs .tab-item {
            padding: 15px 30px;
            font-size: 18px;
            font-weight: 500;
            color: #888;
            cursor: pointer;
        }
        .detail-tabs .tab-item.active {
            color: #333;
            border-bottom: 2px solid #333;
            margin-bottom: -2px; 
        }
        
        /* '상품정보' (설명) */
        .detail-content {
            padding: 30px 20px;
            font-size: 16px;
            line-height: 1.7;
            min-height: 250px;
        }
        .detail-content img {
            max-width: 100%; 
            height: auto;
            margin-top: 15px;
        }
        
        /* --- 푸터 스타일 --- */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 50px;
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
            String currentUserId = (String)session.getAttribute("userId");
            if (currentUserId == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
                <input type="button" value="" onclick="location.href='loginpage.jsp'"
                   style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                   background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
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
                   background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
            <%
            }
            %>
        </div>
    </header>
    
    <div class="detail-wrapper">
        
        <div class="detail-image-section">
            <div class="swiper mySwiper">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <img src="<%= request.getContextPath() + (pMainImg != null ? pMainImg : "/images/logo.png") %>" alt="<%= pName %>">
                    </div>
                    
                    <%
                        for (String imgUrl : detailImages) {
                            if (imgUrl != null && !imgUrl.isEmpty()) {
                    %>
                                <div class="swiper-slide">
                                    <img src="<%= request.getContextPath() + imgUrl %>" alt="상세 이미지">
                                </div>
                    <%
                            }
                        }
                    %>
                </div>
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
                <div class="swiper-pagination"></div>
            </div>
        </div>
        
        <div class="detail-info-section">
            <div class="category"><%= pCategory %></div>
            <h1 class="title"><%= pName %></h1>
            <div class="price"><%= pPrice %>원</div>
            
            <div class="seller-info">
                <strong>판매자:</strong> <%= pSellerNick %>
            </div>
            
            <div class="shipping-info">
                <strong>택배비:</strong>
                <% if (pShippingIncluded) { %>
                    <span class="shipping-tag">택배비 포함 (O)</span>
                <% } else { %>
                    <span>택배비 미포함 (X)</span>
                <% } %>
            </div>
            
            <div class="action-buttons">
                <a href="#" class="action-btn btn-wishlist">찜하기</a>
                <a href="#" class="action-btn btn-buy">바로 구매</a>
            </div>
        </div>
    </div>
    
    <div class="detail-content-wrapper">
        <div class="detail-tabs">
            <div class="tab-item active">상품 정보</div>
            <div class="tab-item">지도 (직거래 위치)</div>
        </div>
        
        <div class="detail-content">
            <%
                if (pDesc != null) {
                    // (XSS 방지) <, > 기호를 HTML 코드로 변경하고, 줄바꿈(\n)을 <br>로 변경
                    out.println(pDesc.replace("<", "&lt;").replace(">", "&gt;").replace("\n", "<br>"));
                }
            %>
        </div>
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
            pagination: {
                el: ".swiper-pagination",
                clickable: true,
            },
            navigation: {
                nextEl: ".swiper-button-next",
                prevEl: ".swiper-button-prev",
            },
        });
    </script>
    
</body>
</html>