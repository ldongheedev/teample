<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 로그인</title>
    <style>
        /* (스타일 코드는 원본과 동일) */
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
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #2c7be5;
        }
        .header-links {
            display: flex; /* ✨ 헤더 링크 정렬을 위해 추가 */
            align-items: center; /* ✨ 헤더 링크 정렬을 위해 추가 */
            gap: 15px; /* ✨ 헤더 링크 정렬을 위해 추가 */
        }
        .header-links a {
            margin-left: 20px;
            text-decoration: none;
            color: #555;
            font-size: 14px;
        }
        .login-section {
            max-width: 400px;
            margin: 80px auto 0;
            padding: 30px 40px;
            background-color: #ffffff;
            border-radius: 10px;
        }
        .login-section h2 {
            display: none;
        }
        form.login-form-box {
            display: flex;
            gap: 10px;
        }
        .input-fields {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .input-fields input[type="text"],
        .input-fields input[type="password"] {
            padding: 12px 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
        }
        input.login-submit-btn {
            width: 100px;
            height: 95px;
            padding: 10px;
            background-color: #81c147;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s ease;
            box-sizing: border-box;
        }
        input.login-submit-btn:hover {
            background-color: #888888;
        }
        .extra-options {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
        }
        .extra-options a {
            color: #333;
            text-decoration: none;
            font-weight: 500;
        }
        .extra-options a:hover {
            text-decoration: underline;
        }
        .social-login-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 20px;
        }
        .social-login-buttons button {
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            background-color: #ffffff;
            color: #333;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .social-login-buttons button:hover {
            background-color: #f0f0f0;
        }
    </style>
    
    <script>
    function validateForm() {
        var id = document.forms[0]["id"].value;
        var pw = document.forms[0]["pw"].value;

        if (id == "" && pw == "") {
            alert("아이디와 비밀번호를 모두 입력하시오.");
            return false;
        } else if (id == "") {
            alert("아이디를 입력하시오.");
            return false;
        } else if (pw == "") {
            alert("비밀번호를 입력하시오.");
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
            <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
            
            <input type="button" value="" onclick="location.href='loginpage.jsp'"
       			style="background: url('images/bell.png') no-repeat center;
        		background-size: contain;
              	width: 40px; height: 40px; border: none; cursor: pointer;"
            />
        </div>
    </header>

    <div class="login-section">
        <% 
        // 로그인 상태 확인
        if ((String)session.getAttribute("userId") != null) { 
        %>
            <form action="logout.jsp" method="post" class="login-form-box">
                <%= (String)session.getAttribute("userName") %>님 로그인 중
    
                <input type="submit" value="로그아웃">
                <input type="button" value="회원정보수정" onclick="window.open('member_update_form.jsp','','width=500,height=200')">
            </form>
        <% 
        } else { 
        // 로그아웃 상태일 때 로그인 폼 표시
        %>
            <form action="login.jsp" method="post" class="login-form-box" onsubmit="return validateForm()">
          
                <div class="input-fields">
                    <input type="text" name="id" placeholder="아이디">
                    <input type="password" name="pw" placeholder="비밀번호">
                </div>
                <input type="submit" value="로그인" class="login-submit-btn">
            
            </form>

            <div class="extra-options">
                <a href="#" onclick="window.open('member_join_form.jsp', 'joinForm', 'width=600,height=800'); return false;">회원가입</a>
                <a href="#">아이디 찾기/비밀번호 찾기</a>
            </div>
            
            <div class="social-login-buttons">
                <button type="button">카카오톡으로 로그인</button>
                <button type="button">네이버로 로그인</button>
            </div>
        <% 
        } 
        %>
    </div>
</body>
</html>
