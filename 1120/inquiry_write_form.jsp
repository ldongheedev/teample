<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<%
    // 1. 로그인 확인
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String isAdmin = (String) session.getAttribute("isAdmin");

    if (userId == null) {
%>
        <script>
            alert("로그인이 필요한 서비스입니다.");
            location.href = "loginpage.jsp";
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>1:1 문의 작성 - 중고모아</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* --- [고정] 상단 헤더 CSS --- */
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
        /* --- [고정] 상단 헤더 CSS 끝 --- */

        /* --- [페이지 전용] 문의 작성 스타일 --- */
        .inquiry-container {
            max-width: 900px; /* 리스트 페이지보다 약간 좁게 집중 */
            margin: 40px auto;
            padding: 40px;
            background-color: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        .inquiry-container h2 {
            font-size: 28px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 40px;
            color: #333;
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
        }
        
        .write-table {
            width: 100%;
            border-collapse: collapse;
        }
        .write-table th, .write-table td {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        .write-table th {
            width: 120px;
            background-color: #f8f9fa;
            text-align: left;
            font-weight: 600;
            color: #555;
        }
        .write-table input[type="text"], 
        .write-table select, 
        .write-table textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 15px;
            box-sizing: border-box;
            outline: none;
            font-family: 'Noto Sans KR', sans-serif;
        }
        .write-table input[type="text"]:focus, 
        .write-table select:focus, 
        .write-table textarea:focus {
            border-color: #2c7be5;
        }
        .write-table textarea {
            height: 300px;
            resize: vertical;
            line-height: 1.6;
        }

        /* 버튼 영역 */
        .btn-area {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 40px;
            font-size: 16px;
            font-weight: 500;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: opacity 0.2s;
        }
        .btn-submit {
            background-color: #333;
            color: white;
        }
        .btn-cancel {
            background-color: #fff;
            color: #333;
            border: 1px solid #ccc;
        }
        .btn:hover {
            opacity: 0.8;
        }

        /* --- [고정] 하단 푸터 CSS --- */
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
        
        function validateForm() {
            var form = document.forms[0];
            if (form.category.value === "") {
                alert("카테고리를 선택해주세요.");
                form.category.focus();
                return false;
            }
            if (form.title.value.trim() === "") {
                alert("제목을 입력해주세요.");
                form.title.focus();
                return false;
            }
            if (form.content.value.trim() === "") {
                alert("내용을 입력해주세요.");
                form.content.focus();
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
                <%= userName %>님, 환영합니다.
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
                background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;"
            />
        </div>
    </header>

    <div class="inquiry-container">
        <h2>1:1 문의 작성</h2>
        
        <form action="inquiry_write_action.jsp" method="post" onsubmit="return validateForm()">
            <table class="write-table">
                <tr>
                    <th>카테고리</th>
                    <td>
                        <select name="category">
                            <option value="">선택해주세요</option>
                            <option value="주문/결제">주문/결제</option>
                            <option value="상품">상품</option>
                            <option value="배송">배송</option>
                            <option value="회원정보">회원정보</option>
                            <option value="기타">기타</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>제목</th>
                    <td>
                        <input type="text" name="title" placeholder="제목을 입력해주세요">
                    </td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td>
                        <textarea name="content" placeholder="문의하실 내용을 자세히 입력해주세요."></textarea>
                    </td>
                </tr>
            </table>
            
            <div class="btn-area">
                <a href="inquiry_list.jsp" class="btn btn-cancel">취소</a>
                <button type="submit" class="btn btn-submit">등록하기</button>
            </div>
        </form>
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