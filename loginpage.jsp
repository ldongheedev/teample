<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 로그인</title>
    <style>
        /* 웹폰트 - Noto Sans KR */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* 헤더 스타일은 원본 코드를 유지하되, 이미지와는 직접 관련이 없어 생략 */
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
        
        /* 로그인 섹션: 이미지와 동일한 레이아웃을 위한 핵심 스타일 */
        .login-section {
            max-width: 400px;
            margin: 80px auto 0; /* 중앙 정렬 및 상단 여백 추가 */
            padding: 30px 40px;
            background-color: #ffffff;
            border-radius: 10px;
            /* box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); /* 이미지는 섀도우가 약해보여 주석 처리 */
        }
        
        .login-section h2 {
            display: none; /* '로그인' 제목은 이미지에 없어 숨김 */
        }

        /* 아이디/비밀번호 입력 폼 스타일 */
        form.login-form-box {
            display: flex;
            gap: 10px; /* 입력 필드와 버튼 간 간격 */
        }

        .input-fields {
            flex-grow: 1; /* 입력 필드 컨테이너가 공간을 최대한 차지하도록 */
            display: flex;
            flex-direction: column;
            gap: 10px; /* 아이디와 비밀번호 입력 필드 간 간격 */
        }

        .input-fields input[type="text"],
        .input-fields input[type="password"] {
            padding: 12px 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
            /* 플레이스홀더를 텍스트로 대체하므로, 별도 라벨은 사용하지 않음 */
        }

        /* 로그인 버튼 스타일 (이미지 속 회색 버튼) */
        input.login-submit-btn {
            width: 100px; /* 이미지 속 버튼과 비슷한 너비 */
            height: 95px; /* 입력 필드 두 개 높이만큼 늘림 */
            padding: 10px;
            background-color: #81c147; /* 연두 배경 */
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s ease;
            box-sizing: border-box; /* 패딩이 너비에 포함되도록 */
        }

        input.login-submit-btn:hover {
            background-color: #888888;
        }

        /* 부가 옵션 (회원가입, ID/PW 찾기) 스타일 */
        .extra-options {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            padding-bottom: 20px; /* 소셜 로그인 버튼과의 간격 */
            border-bottom: 1px solid #eee; /* 이미지에 없는 구분선이 필요하다면 사용 */
            display: flex;
            justify-content: space-between;
        }

        .extra-options a {
            color: #333; /* 검정색에 가깝게 설정 */
            text-decoration: none;
            font-weight: 500;
        }

        .extra-options a:hover {
            text-decoration: underline;
        }
        
        /* 소셜 로그인 버튼 스타일 */
        .social-login-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 20px;
        }

        .social-login-buttons button {
            padding: 12px;
            border: 1px solid #ccc; /* 이미지와 비슷한 옅은 테두리 */
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
        // 아이디 필드 (name="id")와 비밀번호 필드 (name="pw") 값을 가져옵니다.
        var id = document.forms[0]["id"].value; 
        var pw = document.forms[0]["pw"].value;

        if (id == "" && pw == "") {
            alert("아이디와 비밀번호를 모두 입력하시오.");
            return false;
        } else if (id == "") {
            alert("아이디를 입력하시오.");
            return false;
        } else if (pw == "") {
            // 요청하신 조건: 아이디만 입력했을 때 ('아이디를 입력하시오.'를 '비밀번호를 입력하시오.'로 잘못 쓰신 것으로 가정하고)
            alert("비밀번호를 입력하시오.");
            return false;
        }
        // 모든 유효성 검사를 통과하면 true를 반환하여 폼이 제출되도록 합니다.
        return true;
    }
    </script>
</head>
<body>
    <header>
        <div class="logo">
    		<img src="images/logo.png" style="height: 60px; width: 200">
		</div>
        <div class="header-links">
            <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
            <input type="button" value="" onclick="location.href='loginpage.jsp'"
       			style="background: url('images/bell.png') no-repeat center;
              	background-size: contain;
              	width: 40px; height: 40px; border: none; cursor: pointer;" />
        </div>
    </header>

    <div class="login-section">
        <% 
        // 기존 JSP 로직 (로그인/로그아웃 상태 처리)
        if ((String)session.getAttribute("userId") != null) { 
        %>
            <form action="logout.jsp" method="post" class="login-form-box">
                <%= (String)session.getAttribute("userName") %>님 로그인 중
                <input type="submit" value="로그아웃">
                <input type="button" value="회원정보수정" onclick="window.open('member_update_form.jsp','','width=500,height=200')">
            </form>
        <% 
        } else { 
        %>
            <form action="login.jsp" method="post" class="login-form-box" onsubmit="return validateForm()">
                <div class="input-fields">
                    <input type="text" name="id" placeholder="아이디">
                    <input type="password" name="pw" placeholder="비밀번호">
                </div>
                <input type="submit" value="로그인" class="login-submit-btn">
            </form>

            <div class="extra-options">
                <a href="#" onclick="location.href='member_join_form.jsp'; return false;">회원가입</a>
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