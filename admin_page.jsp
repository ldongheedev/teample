<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %> <%-- ✨ 1. DB 연동을 위해 import (회원/상품 목록 조회 시 필요) --%>

<%
    // ✨ 2. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    
    // 세션이 없거나, "true"가 아니면
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("접근 권한이 없습니다.");
            location.href = "main_page.jsp"; // 메인 페이지로 이동
        </script>
<%
        return; // (중요) HTML 코드 실행 중단
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    
    <style>
        /* CSS 시작 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* --- ✨ 3. 헤더 스타일 (main_page.jsp에서 복사) --- */
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

        /* --- ✨ 4. 관리자 페이지 레이아웃 (신규) --- */
        .admin-wrapper {
            display: flex;
            max-width: 1400px; /* 최대 너비 */
            min-height: 70vh; /* 최소 높이 */
            margin: 20px auto; /* 중앙 정렬 */
            gap: 20px; /* 사이드바와 컨텐츠 간격 */
        }

        /* 관리자 사이드바 */
        .admin-sidebar {
            width: 220px;
            flex-shrink: 0; /* 줄어들지 않음 */
            background-color: #ffffff;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        .admin-sidebar h3 {
            font-size: 18px;
            color: #333;
            margin-top: 0;
            margin-bottom: 10px;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
        .admin-sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0 0 20px 0;
        }
        .admin-sidebar li a {
            display: block;
            padding: 12px 15px;
            text-decoration: none;
            color: #555;
            font-size: 15px;
            border-radius: 6px;
        }
        .admin-sidebar li a:hover {
            background-color: #f5f5f5;
        }
        .admin-sidebar li.active a {
            background-color: #2c7be5; /* 활성 메뉴 색상 */
            color: white;
            font-weight: 500;
        }

        /* 관리자 컨텐츠 영역 */
        .admin-content {
            flex-grow: 1; /* 남은 공간 모두 차지 */
            background-color: #ffffff;
            padding: 30px 40px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        
        .admin-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }
        
        .admin-header h2 {
            font-size: 24px;
            margin: 0;
        }
        
        .delete-btn {
            background-color: #d9534f; /* 삭제 버튼 (빨간색) */
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 15px;
            font-weight: 500;
            border-radius: 5px;
            cursor: pointer;
        }
        .delete-btn:hover {
            background-color: #c9302c;
        }

        /* 관리자용 상품 그리드 (스토리보드 69p 참고) */
        .product-grid-admin {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .product-card-admin {
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 15px;
            background-color: #fafafa;
        }
        .product-card-admin .img-placeholder {
            width: 100%;
            height: 150px;
            background-color: #e0e0e0;
            border-radius: 6px;
            margin-bottom: 10px;
        }
        .product-card-admin p {
            margin: 5px 0 0 0;
            font-size: 14px;
            color: #333;
        }
        .product-card-admin .price {
            font-weight: bold;
            font-size: 15px;
        }
        .product-card-admin .checkbox-area {
            display: flex;
            justify-content: flex-end;
            margin-top: 10px;
        }

        /* --- ✨ 5. 푸터 스타일 (main_page.jsp에서 복사) --- */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 50px; /* 컨텐츠와 간격 */
        }
        .footer-section h4 { ... }
        .footer-section p, .footer-section a { ... }
        .admin-link { ... }
        .admin-link:hover { ... }
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
            <div class="welcome-message">
                <%= (String)session.getAttribute("userName") %>님 (관리자), 환영합니다.
            </div>
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                <div id="myDropdown" class="dropdown-content">
                    <a href="#">마이페이지</a>
                    <a href="logout.jsp">로그아웃</a>
                </div>
            </div>
            <input type="button" value="" onclick="location.href='notifications.jsp'"
               style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
               background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
        </div>
    </header>
    
    <div class="admin-wrapper">
        
        <nav class="admin-sidebar">
            <h3>상품 관리</h3>
            <ul>
                <li class="active"><a href="admin_page.jsp">상품 삭제</a></li> 
                <li><a href="#">상품 정보 수정</a></li> </ul>
            
            <h3>고객 센터</h3> <ul>
                <li><a href="#">1:1 문의</a></li> <li><a href="#">FAQ</a></li> <li><a href="#">공지사항</a></li> </ul>
            
            <h3>통계</h3> <ul>
                <li><a href="#">전체 통계</a></li> </ul>
        </nav>
        
        <main class="admin-content">
            
            <div class="admin-header">
                <h2>상품 삭제</h2> <button class="delete-btn" onclick="alert('삭제 확인 창 (추후 구현)')">삭제하기</button> </div>
            
            <div class="product-grid-admin">
                <%-- (DB 연동) 나중에 DB에서 실제 상품 목록을 불러와 반복 --%>
                <% for (int i = 0; i < 6; i++) { %>
                    <div class="product-card-admin">
                        <div class="img-placeholder"></div>
                        <p>상품이름 [<%= i+1 %>]</p> <p>상품분류</p> <p class="price">가격</p> <div class="checkbox-area">
                            <input type="checkbox"> </div>
                    </div>
                <% } %>
            </div>
            
        </main>
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
                <br>
                <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
    		</div>
		</div>
    </footer>
    
    </body>
</html>