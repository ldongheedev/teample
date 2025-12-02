<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <style>
        /* 기존 스타일 그대로 유지 */
        /* ... (생략 없이 원래 있던 CSS 내용 그대로 두시면 됩니다) ... */
    </style>
</head>
<body>
    <script>
        <% String msg = (String)request.getAttribute("msg"); %>
        <% if(msg != null) { %>
            alert("<%= msg %>");
        <% } %>
    </script>

    <form action="member" method="post">
        <input type="hidden" name="cmd" value="login">
        
        <input type="text" name="id" placeholder="아이디" required>
        <input type="password" name="pw" placeholder="비밀번호" required>
        
        <button type="submit">로그인</button>
    </form>

    </body>
</html>