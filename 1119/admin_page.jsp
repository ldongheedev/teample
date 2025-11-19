<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    String isAdmin = (String) session.getAttribute("isAdmin");
    String userName = (String) session.getAttribute("userName");
    
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("접근 권한이 없습니다.");
            location.href = "main_page.jsp"; 
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    
    <style>
        /* [ ... CSS 스타일은 원본과 동일하게 유지됩니다 ... ] */
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
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }
        .admin-wrapper {
            display: flex;
            max-width: 1400px;
            min-height: 70vh;
            margin: 20px auto;
            gap: 20px;
        }
        .admin-sidebar {
            width: 220px;
            flex-shrink: 0;
            background-color: #ffffff;
            padding: 20px 0;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            align-self: flex-start;
        }
        .admin-sidebar h3 {
            font-size: 16px;
            color: #2c7be5;
            padding: 10px 20px;
            margin-top: 15px;
            margin-bottom: 5px;
            border-bottom: 1px solid #eee;
        }
        .admin-sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .admin-sidebar li a {
            display: block;
            padding: 12px 20px;
            text-decoration: none;
            color: #333;
            font-size: 14px;
            transition: background-color 0.1s;
        }
        .admin-sidebar li a:hover {
            background-color: #f5f5f5;
        }
        .admin-sidebar li.active a {
            background-color: #2c7be5;
            color: white;
            font-weight: 500;
        }
        .admin-content {
            flex-grow: 1;
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
            background-color: #d9534f;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 15px;
            font-weight: 500;
            border-radius: 5px;
            cursor: pointer;
        }
        .product-list-admin {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
        }
        .product-card-admin {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .img-placeholder {
            width: 100%;
            height: 150px;
            background-color: #eee;
            margin-bottom: 10px;
            border-radius: 4px;
        }
        .product-card-admin p {
            margin: 5px 0;
            font-size: 14px;
        }
        .product-card-admin .price {
            font-weight: 700;
            color: #2c7be5;
        }
        .checkbox-area {
            margin-top: 10px;
        }
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
                <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;" alt="중고모아 로고">
            </a>
        </div>
        
        <div class="header-links">
            <div class="welcome-message">
                관리자 <%= userName %>님, 환영합니다. 
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
        </div>
        </header>

    <div class="admin-wrapper">
        <nav class="admin-sidebar">
            <h3>회원 관리</h3>
            <ul>
                <li><a href="#">회원 목록</a></li> 
                <li><a href="#">회원 정지/탈퇴</a></li> 
            </ul>
            
            <h3>상품 관리</h3>
            <ul>
                <li><a href="#">상품 목록</a></li> 
                <li><a href="#">상품 등록 (미사용)</a></li> 
            </ul>

            <h3>고객 지원</h3>
            <ul>
                <li><a href="#">1:1 문의</a></li> 
                <li><a href="faq_list.jsp">FAQ</a></li> 
                <li><a href="notice_list.jsp">공지사항</a></li> 
            </ul>

            <h3>통계</h3>
            <ul>
                <li><a href="#">전체 통계</a></li> 
            </ul>
        </nav>
        
        <main class="admin-content">
            <div class="admin-header">
                <h2>상품 삭제</h2>
                <button class="delete-btn" onclick="alert('삭제 확인 창 (추후 구현)')">삭제하기</button> 
            </div>
            
            <div class="product-list-admin">
                <% for (int i = 0; i < 6; i++) { %>
                    <div class="product-card-admin">
                        <div class="img-placeholder"></div>
                        <p>상품이름 [<%= i+1 %>]</p>
                        <p>상품분류</p> 
                        <p class="price">가격</p>
                        <div class="checkbox-area">
                            <input type="checkbox">
                        </div>
                    </div>
                <% } %>
            </div>
            
        </main>
    </div>

    <footer>
        <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;" alt="로고2">
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
        		<a href="inquiry_list.jsp"> <%= question %> </a><br>
        		<a href="faq_list.jsp"> <%= faq %> </a>
                <br>
                <a href="admin_page.jsp" class="admin-link">관리자 페이지</a> 
    		</div>
		</div>
    </footer>

</body>
</html>