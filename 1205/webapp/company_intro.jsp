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

        
        /* 2. 메인 콘텐츠 스타일 */
        .content-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 40px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        h2 {
            font-size: 28px;
            color: #2c7be5;
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        .intro-section {
            margin-bottom: 30px;
        }
        .intro-section h3 {
            color: #549e39;
            font-size: 20px;
            margin-bottom: 15px;
            border-left: 5px solid #549e39;
            padding-left: 10px;
        }
        .intro-section p {
            line-height: 1.6;
            color: #555;
            margin-bottom: 10px;
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
        /* 로고 스타일은 헤더 CSS에 정의되어 있음 */

    </style>
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
                        <a href="member?cmd=logout">로그아웃</a>
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


        <div class="content-container">
            <h2>중고모아는 어떤 곳인가요?</h2>
            
            <div class="intro-section">
                <h3>미션과 비전</h3>
                <p>
                    중고모아는 사용되지 않는 물건에 새 생명을 불어넣고, 모든 사람이 쉽고 안전하게 중고 물품을 거래할 수 있는 플랫폼을 만드는 것을 목표로 합니다.
                </p>
                <p>
                    우리의 비전은 **'지속 가능한 소비'**를 통해 환경을 보호하고, 동시에 사용자들에게는 **'합리적인 경제 생활'**을 제공하는 것입니다.
                </p>
            </div>
            
            <div class="intro-section">
                <h3>핵심 가치</h3>
                <p>
                    **안전한 거래**: 투명한 시스템과 철저한 본인 인증을 통해 신뢰를 구축합니다.
                </p>
                <p>
                    **쉬운 사용성**: 누구나 쉽게 상품을 등록하고 검색하며 거래할 수 있도록 간편한 인터페이스를 제공합니다.
                </p>
                <p>
                    **다양한 물품**: 의류부터 디지털 기기, 재능까지 다양한 카테고리의 거래를 지원합니다.
                </p>
            </div>
            
            <div class="intro-section">
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
                <a href="customer?cmd=noticeList"> <%= notice %> </a><br>
            </div>
            <div class="footer-section">
                <h4>SUPPORT</h4>
                <a href="customer?cmd=inquiryList"> <%= question %> </a><br>
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