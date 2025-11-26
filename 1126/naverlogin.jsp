<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.math.BigInteger" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>네이버 로그인 인증 중</title>
  </head>
  <body>
  <%
    // ✨ 클라이언트 ID 설정
    String clientId = "SzhvAQKSGeClXT4Qe7H2";
    
    // ✨ 콜백 URL 설정 (naver_callback.jsp로 지정)
    String callbackUrl = "http://localhost:8090/teamProjectPr/naver_callback.jsp";
    String redirectURI = URLEncoder.encode(callbackUrl, "UTF-8");
    
    // CSRF 공격 방지를 위한 상태 토큰 생성
    SecureRandom random = new SecureRandom();
    String state = new BigInteger(130, random).toString();
    
    // 세션에 상태 토큰 저장 (콜백 페이지에서 검증하기 위함)
    session.setAttribute("state", state);
    
    // 네이버 인증 요청 API URL 생성
    String apiURL = "https://nid.naver.com/oauth2.0/authorize?response_type=code"
         + "&client_id=" + clientId
         + "&redirect_uri=" + redirectURI
         + "&state=" + state;
    
    // 네이버 로그인 창으로 즉시 리다이렉션
    response.sendRedirect(apiURL);
 %>
  
  </body>
</html>