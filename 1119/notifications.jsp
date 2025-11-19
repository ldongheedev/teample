<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 - 알림</title>
    
    <style>
        /* CSS 시작 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* --- ✨ 1. 헤더 스타일 (main_page.jsp에서 가져옴) --- */
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

        /* --- ✨ 2. 알림 페이지 전용 스타일 (신규) --- */
        .notification-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px 40px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            min-height: 500px;
        }
        
        .notification-container h2 {
            font-size: 24px;
            margin-bottom: 25px;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
        }
        
        .notification-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .notification-item {
            display: flex;
            align-items: center;
            padding: 20px 10px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.2s;
        }
        
        .notification-item:hover {
            background-color: #f9f9f9;
        }
        
        .notification-icon {
            font-size: 24px;
            margin-right: 20px;
        }
        
        .notification-content .message {
            font-size: 16px;
            color: #333;
            font-weight: 500;
        }
        
        .notification-content .timestamp {
            font-size: 14px;
            color: #888;
            margin-top: 5px;
        }
        
        .notification-item.type-chat .notification-icon::before {
            content: '💬';
        }
        .notification-item.type-admin .notification-icon::before {
            content: '📢';
        }
        
        /* --- ✨ 3. 푸터 스타일 (main_page.jsp에서 가져옴) --- */
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
                        <a href="#">마이페이지</a>
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
    
    <div class="notification-container">
        <h2>알림</h2>
        
        <ul class="notification-list">
            <li class="notification-item type-admin">
                <div class="notification-icon"></div>
                <div class="notification-content">
                    <div class="message">[공지] '중고모아' 서비스 점검 안내 (오전 2시~4시)</div>
                    <div class="timestamp">1시간 전</div>
                </div>
            </li>
            
            <li class="notification-item type-chat">
                <div class="notification-icon"></div>
                <div class="notification-content">
                    <div class="message">'강남멋쟁이'님이 메시지 요청을 수락했습니다.</div>
                    <div class="timestamp">3시간 전</div>
                </div>
            </li>

            <li class="notification-item type-chat">
                <div class="notification-icon"></div>
                <div class="notification-content">
                    <div class="message">'해피바이러스'님이 '닌텐도 스위치' 상품에 대해 거래 요청을 보냈습니다.</div>
                    <div class="timestamp">1일 전</div>
                </div>
            </li>
            
            <li class="notification-item type-admin">
                <div class="notification-icon"></div>
                <div class="notification-content">
                    <div class="message">[이벤트] 추석맞이 10% 할인 쿠폰이 발급되었습니다.</div>
                    <div class="timestamp">2일 전</div>
                </div>
            </li>
        </ul>
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
        		<a href="inquiry_list.jsp"> <%= question %> </a><br>
        		<a href="faq_list.jsp"> <%= faq %> </a>
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
    
    </body>
</html>