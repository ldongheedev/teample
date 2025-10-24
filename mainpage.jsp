<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아</title>
    
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <style>
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
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #2c7be5;
        }
        .header-links a {
            margin-left: 20px;
            text-decoration: none;
            color: #555;
            font-size: 14px;
        }
        
        /* ▼▼▼ [수정] 햄버거, 검색창, 카테고리 관련 스타일 ▼▼▼ */
        
        /* 햄버거+검색창+카테고리 전체를 감싸는 컨테이너 */
        .search-area-container {
            /* max-width와 margin:auto를 제거하여 full-width로 변경 */
            margin: 30px 0 0 0;
            padding: 0 40px; /* header와 동일한 좌우 패딩 적용 */
            position: relative; 
            display: flex; /* 햄버거 버튼과 검색창을 정렬하기 위해 flex 사용 */
            align-items: center;
        }

        /* 햄버거 버튼 (flex-item 1) */
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
            flex-shrink: 0; /* 줄어들지 않게 함 */
        }
        
        #hamburger-btn span {
            display: block;
            width: 100%;
            height: 3px;
            background-color: #333;
            border-radius: 3px;
        }
        
        /* 검색창 중앙 정렬용 래퍼 (flex-item 2) */
        .search-bar {
            flex-grow: 1; /* 남은 공간을 모두 차지 */
            display: flex;
            justify-content: center; /* 자식 요소(검색창)를 중앙 정렬 */
        }
        
        /* 실제 검색창 (input + x button) */
        .search-bar .search-input-wrapper {
             position: relative;
             display: flex; 
             align-items: center;
             width: 100%;
             max-width: 500px; /* 검색창의 최대 너비 고정 */
        }

        .search-bar input {
            width: 100%; /* 부모(wrapper) 너비를 꽉 채움 */
            padding: 12px 16px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
        }

        /* 카테고리 메뉴 (absolute) */
        .category-nav {
            display: none; /* 평소에 숨김 */
            position: absolute; 
            top: 100%; /* .search-area-container 바로 아래 */
            
            /* 중앙 정렬을 위해 left 50% + transform 사용 */
            left: 50%;
            transform: translateX(-50%);
            
            width: 100%;
            max-width: 700px; /* 스와이퍼와 동일한 너비로 설정 */
            
            background-color: #ffffff;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            z-index: 1000;
        }
        
        .category-nav.show {
            display: block; 
        }

        /* 카테고리 메뉴 내부 padding */
        .category-nav ul {
            list-style: none;
            margin: 0;
            padding: 10px 40px; 
        }
        
        .category-nav ul li:first-child a {
            font-weight: bold;
            color: #2c7be5; 
            font-size: 18px;
            border-bottom: 1px solid #eee;
            margin-bottom: 10px;
            padding-bottom: 15px;
            cursor: default;
        }
        .category-nav ul li:first-child a:hover {
            background-color: transparent; 
        }

        .category-nav li a {
            display: block;
            padding: 8px 0; 
            text-decoration: none;
            color: #333;
            font-size: 15px;
        }

        .category-nav li a:hover {
            background-color: #f5f5f5;
        }
        
        /* ▲▲▲ [수정] 끝 ▲▲▲ */


        /* 나머지 기존 CSS */
        .recommend-section {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
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
            height: 200px;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #aaa;
            font-size: 14px;
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
    </style>
</head>
<body>

<%
    request.setCharacterEncoding("UTF-8");

    // 로그인 시도 시 DB 확인
    String id = request.getParameter("id");
    String pw = request.getParameter("pw");

    // 로그아웃 처리
    if (request.getParameter("logout") != null) {
        session.invalidate();
        response.sendRedirect("main.jsp");
        return;
    }

    // DB 연결
    if (id != null && pw != null) {
        Class.forName("org.mariadb.jdbc.Driver");
        try (
            Connection conn = DriverManager.getConnection(
                "jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(String.format(
                "SELECT * FROM member WHERE id='%s' AND pw='%s'",
                id, pw));
        ) {
            if (rs.next()) {
                session.setAttribute("userId", rs.getString("id"));
                session.setAttribute("userName", rs.getString("name"));
                response.sendRedirect("main.jsp");
                return;
            } else {
%>
                <script>
                    alert("아이디 또는 비밀번호가 틀립니다!");
                </script>
<%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>DB 오류: " + e.getMessage() + "</p>");
        }
    }

    String userName = (String) session.getAttribute("userName");
%>

    <header>
        <div class="logo">
    		<img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px;">
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
        
        <button id="hamburger-btn">
            <span></span>
            <span></span>
            <span></span>
        </button>
        
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
                    aria-label="지우기">
                    ✕
                </button>
            </div>
        </div>
        
        <nav class="category-nav" id="category-menu">
            <ul>
                <li><a href="#" onclick="return false;">전체 카테고리</a></li>
                <li><a href="#">의류</a></li>
                <li><a href="#">식품</a></li>
                <li><a href="#">액세서리</a></li>
                <li><a href="#">디지털/가전제품</a></li>
                <li><a href="#">스포츠 용품</a></li>
                <li><a href="#">애완동물용품</a></li>
                <li><a href="#">재능</a></li>
            </ul>
        </nav>
    </div>
    <div class="swiper mySwiper" style="width: 100%; max-width: 700px; margin: 30px auto 0 auto;">
  		<div class="swiper-wrapper">
			<div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/img1.png" alt="이미지1" style="width: 100%; height: 300px; object-fit: contain; background-color: #eee;"></div>
			<div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/img2.jpg" alt="이미지2" style="width: 100%; height: 300px; object-fit: contain; background-color: #eee;"></div>
			<div class="swiper-slide"><img src="<%= request.getContextPath() %>/images/img3.jpg" alt="이미지3" style="width: 100%; height: 300px; object-fit: contain; background-color: #eee;"></div>
        </div>
  		<div class="swiper-pagination"></div>
  		<div class="swiper-button-prev"></div>
  	    <div class="swiper-button-next"></div>
	</div>

    <section class="recommend-section">
        <h2>상품 추천</h2>
        <div class="product-grid">
            <% for (int i = 0; i < 8; i++) { %>
                <div class="product-card">상품 추천 이미지</div>
            <% } %>
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
    
    <script>
    // 기존 Swiper 초기화
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

    // 햄버거 버튼 클릭 이벤트 (JS는 변경 없음)
    const hamburgerBtn = document.getElementById('hamburger-btn');
    const categoryMenu = document.getElementById('category-menu');

    hamburgerBtn.addEventListener('click', function() {
        categoryMenu.classList.toggle('show');
    });
</script>
    
</body>
</html>