<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    Boolean isFound = (Boolean) request.getAttribute("isFound");
    String resultLabel = (String) request.getAttribute("resultLabel");
    String resultText = (String) request.getAttribute("resultText");
    
    if (isFound == null) isFound = false; // 방어 코드
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>찾기 결과</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            color: #333;
        }
        .result-container {
            width: 400px;
            background-color: #ffffff;
            border: 1px solid #ccc;
            padding: 40px 30px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            border-radius: 8px;
            text-align: center;
        }
        .icon { font-size: 50px; margin-bottom: 20px; display: block;}
        .success { color: #81c147; }
        .fail { color: #d9534f; }
        
        h3 { margin: 10px 0 20px 0; font-size: 20px; }
        
        .result-box {
            background-color: #f1f8ff;
            border: 1px dashed #2c7be5;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
            color: #2c7be5;
            font-weight: 700;
            font-size: 18px;
        }
        
        .msg { font-size: 14px; color: #666; line-height: 1.6; }
        
        .btn-close {
            display: inline-block;
            padding: 10px 30px;
            background-color: #555;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            margin-top: 20px;
            transition: background-color 0.2s;
        }
        .btn-close:hover { background-color: #333; }
        
        .btn-retry {
            display: inline-block;
            padding: 10px 30px;
            background-color: #2c7be5;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            margin-top: 20px;
            margin-right: 10px;
        }
    </style>
</head>
<body>

<div class="result-container">
    <% if (isFound) { %>
        <span class="icon success">✔</span>
        <h3>회원님의 <%= resultLabel %>를 찾았습니다.</h3>
        
        <div class="result-box">
            <%= resultText %>
        </div>
        
        <p class="msg">
            확인 버튼을 누르면 창이 닫힙니다.<br>
            로그인 페이지에서 로그인해주세요.
        </p>
        
        <a href="#" onclick="window.close();" class="btn-close">확인</a>
        
    <% } else { %>
        <span class="icon fail">!</span>
        <h3>정보를 찾을 수 없습니다.</h3>
        
        <p class="msg">
            입력하신 정보와 일치하는 회원이 없습니다.<br>
            입력 정보를 다시 한 번 확인해주세요.
        </p>
        
        <a href="javascript:history.back()" class="btn-retry">다시 시도</a>
        <a href="#" onclick="window.close();" class="btn-close">닫기</a>
    <% } %>
</div>

</body>
</html>