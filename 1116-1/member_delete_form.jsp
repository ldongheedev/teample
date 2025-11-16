<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    String userId = (String) session.getAttribute("userId");
    // ✨ 관리자 탈퇴 방지 로직 추가 (1/2): isAdmin 세션 가져오기
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (userId == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "loginpage.jsp";
        </script>
<%
        return;
    }

    // ✨ 관리자 탈퇴 방지 로직 추가 (2/2): 관리자 계정 접근 차단
    if (isAdmin != null && isAdmin.equals("true")) {
%>
        <script>
            alert("관리자 계정은 탈퇴할 수 없습니다.");
            location.href = "mypage.jsp";
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 회원 탈퇴</title>
    
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
        .mypage-wrapper {
            display: flex;
            max-width: 1400px;
            min-height: 70vh;
            margin: 20px auto;
            gap: 20px;
        }
        .mypage-sidebar {
            width: 220px;
            flex-shrink: 0;
            background-color: #ffffff;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
            height: fit-content;
        }
        .mypage-sidebar h3 {
            font-size: 18px;
            color: #333;
            margin-top: 0;
            margin-bottom: 10px;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
        .mypage-sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0 0 20px 0;
        }
        .mypage-sidebar li a {
            display: block;
            padding: 12px 15px;
            text-decoration: none;
            color: #555;
            font-size: 15px;
            border-radius: 6px;
        }
        .mypage-sidebar li a:hover {
            background-color: #f5f5f5;
        }
        .mypage-sidebar li.active a {
            background-color: #81c147;
            color: white;
            font-weight: 500;
        }
        .mypage-content {
            flex-grow: 1;
            background-color: #ffffff;
            padding: 30px 40px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        .mypage-content h2 {
            font-size: 24px;
            margin-top: 0;
            margin-bottom: 25px;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
        }
        .delete-form table {
            width: 100%;
            border-collapse: collapse;
            border-top: 2px solid #333;
        }
        .delete-form th, .delete-form td {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        .delete-form th {
            width: 150px;
            background-color: #fcfcfc;
            text-align: left;
            vertical-align: middle;
            font-weight: 500;
        }
        .delete-form input[type="password"] {
            width: 100%;
            padding: 10px;
            font-size: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .delete-form .required::before {
            content: "*";
            color: red; 
            margin-right: 5px;
        }
        .form-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
        }
        .form-buttons input {
            padding: 12px 30px;
            font-size: 16px;
            font-weight: 500;
            border-radius: 5px;
            border: 1px solid #ccc;
            cursor: pointer;
        }
        .form-buttons input[type="submit"] {
            background-color: #d9534f;
            color: white;
            border-color: #d9534f;
        }
        .form-buttons input[type="button"] {
            background-color: #fff;
            color: #333;
        }
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
        .footer-section p, .footer-section a {
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
        
        function validateDeleteForm() {
            var form = document.forms[0];
            var currentPw = form.current_pw.value;

            if (currentPw.trim() === "") {
                alert("회원 탈퇴를 위해 현재 비밀번호를 입력해주세요.");
                form.current_pw.focus();
                return false; 
            }

            var isConfirmed = confirm("정말 탈퇴하시겠습니까?\n모든 정보가 영구적으로 삭제되며 복구할 수 없습니다.");
            if (isConfirmed == false) {
                return false;
            }

            return true;
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
        </div>
    </header>
    
    <div class="mypage-wrapper">
        
        <nav class="mypage-sidebar">
            <h3>회원정보</h3>
            <ul>
                <li><a href="member_update_form.jsp">정보 수정</a></li>
                <li class="active"><a href="member_delete_form.jsp">회원 탈퇴</a></li>
            </ul>
            
            <h3>쇼핑정보</h3>
            <ul>
                <%-- ✨ [수정] 찜리스트 링크 연결 --%>
                <li><a href="wishlist.jsp">찜리스트</a></li>
				<li><a href="trade_list.jsp">거래조회</a></li>
            </ul>
      
            <h3>상품관리</h3>
            <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
     
            <h3>고객센터</h3>
            <ul>
                <li><a href="#">1:1 문의</a></li>
                <li><a href="faq_list.jsp">FAQ</a></li>
            </ul>
        </nav>
        
        <main class="mypage-content">
            <h2>회원 탈퇴</h2>
            
            <form class="delete-form" action="member_delete_action.jsp" method="post" onsubmit="return validateDeleteForm();">
                <table>
                    <tbody>
                        <tr>
                            <td colspan="2" style="border-bottom:none; padding-bottom: 20px;">
                                <p style="margin-top:0; line-height: 1.6;">
                                    회원 탈퇴를 신청하시기 전에 안내 사항을 꼭 확인해주세요.<br>
                                    - 회원 탈퇴 시, 계정의 모든 정보(상품, 찜 목록 등)는 즉시 삭제되며 복구할 수 없습니다.<br>
                                    - 본인 확인을 위해 현재 계정의 비밀번호를 입력해주세요.
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <th class="required">현재 비밀번호</th>
                            <td>
                                <input type="password" name="current_pw" placeholder="비밀번호를 입력하세요" required>
                            </td>
                        </tr>
                    </tbody>
                </table>
                
                <div class="form-buttons">
                    <input type="button" value="취소" onclick="location.href='mypage.jsp'">
                    <input type="submit" value="회원 탈퇴">
                </div>
            </form>
            
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
        		<a href="company_intro.jsp"> <%= companyIntro %> </a><br>
        		<a href="notice_list.jsp"> <%= notice %> </a><br>
    		</div>
    		<div class="footer-section">
        		<h4>SUPPORT</h4>
        		<a href="#"> <%= question %> </a><br>
        		<a href="faq_list.jsp"> <%= faq %> </a>
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