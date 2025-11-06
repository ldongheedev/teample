<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 - 회사 소개</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* 1. 헤더 스타일 */
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


        /* 2. 메인 콘텐츠 영역 (회사 소개) */
        .page-content {
            width: 80%;
            max-width: 1200px;
            margin: 40px auto;
            padding: 30px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }

        .page-content h2 {
            font-size: 28px;
            font-weight: 700;
            color: #2c7be5; 
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 30px;
        }

        .info-section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
        }

        .info-section h3 {
            font-size: 20px;
            color: #555;
            margin-bottom: 15px;
            border-left: 4px solid #2c7be5;
            padding-left: 10px;
        }

        .info-section p {
            line-height: 1.8;
            color: #666;
            margin-bottom: 10px;
        }

        .highlight {
            font-weight: 700;
            color: #2c7be5;
        }

        /* 3. 푸터 스타일 */
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

    <%
        String userId = (String) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");
        String isAdmin = (String) session.getAttribute("isAdmin"); 
    %>
    
    <header>
        <div class="logo">
            <a href="main_page.jsp">
                <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;" alt="중고모아 로고">
            </a>
        </div>
        <div class="header-links">
        
            <%
            if (userId == null) {
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
                    <%= userName %>님, 환영합니다.
                </div>

                <input type="button" value="" onclick="location.href='notifications.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
                
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                        <a href="product_add_form.jsp">상품 등록</a>
                    </div>
                </div>
                
            <%
            }
            %>
        </div>
    </header>

    <div class="page-content">
        <h2>회사 소개: (주) 중고모아</h2>

        <div class="info-section">
            <h3>우리의 비전</h3>
            <p>
                (주) 중고모아는 <span class="highlight">신뢰를 바탕으로 한 중고 거래 문화</span>를 선도합니다. 
                모든 사용자가 안심하고 자신의 물품을 거래하며, 환경 보호와 경제적 가치를 동시에 실현할 수 있는 플랫폼을 만드는 것이 우리의 비전입니다.
            </p>
        </div>

        <div class="info-section">
            <h3>핵심 가치</h3>
            <p>
                * **신뢰**: 투명한 정보 공개와 안전 거래 시스템을 통해 사용자 간의 신뢰를 최우선으로 합니다.
            </p>
            <p>
                * **편리성**: 직관적이고 쉬운 인터페이스로 누구나 쉽고 빠르게 상품을 등록하고 거래할 수 있도록 지원합니다.
            </p>
            <p>
                * **지속가능성**: 중고 물품 거래를 통해 자원의 재활용을 촉진하고 지속가능한 소비 문화를 구축합니다.
            </p>
        </div>

        <div class="info-section">
            <h3>회사 정보</h3>
            <p>
                **회사명**: (주) 중고모아
            </p>
            <p>
                **대표**: 김령균
            </p>
            <p>
                **사업자등록번호**: XXX-XX-XXXXX
            </p>
            <p>
                **주소**: 경기도 XX시 XX구 XX로 XX번
            </p>
            <p>
                **연락처**: 010-0000-0000 | junggomoa@gmail.com
            </p>
        </div>
    </div>

    <footer>
        <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;" alt="로고" />
            <p>(주) 중고모아 | 대표 김령균</p>
            <p>TEL : 010-0000-0000</p>
            <p>Mail : junggomoa@gmail.com</p>
            <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
            <p>이용약관 / 개인정보처리방침</p>
        </div>
        
        <div style="display: flex; gap: 40px;">
            <div class="footer-section">
                <h4>ABOUT</h4>
                <a href="company_intro.jsp"> 회사소개 </a><br>
                <a href="notice_list.jsp"> 공지사항 </a><br>
            </div>
            <div class="footer-section">
                <h4>SUPPORT</h4>
                <a href="#"> 1:1 문의 </a><br>
                <a href="#"> FAQ </a>
                
                <%
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