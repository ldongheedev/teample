<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.parser.JSONParser" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
  <head>
    <title>네이버 로그인 처리</title>
  </head>
  <body>
  <%
    // ✨ 클라이언트 정보 설정
    String clientId = "SzhvAQKSGeClXT4Qe7H2";
    String clientSecret = "D6YeFGYlTm";
    
    // ✨ 콜백 URL 설정 (naverlogin.jsp와 동일해야 함)
    String callbackUrl = "http://localhost:8090/teamProjectPr/naver_callback.jsp";
    String redirectURI = URLEncoder.encode(callbackUrl, "UTF-8");
    
    // 네이버로부터 받은 파라미터
    String code = request.getParameter("code");
    String state = request.getParameter("state");
    
    // CSRF 방지 토큰 검증
    String sessionState = (String) session.getAttribute("state");
    if (sessionState == null || !sessionState.equals(state)) {
        out.println("<h1>인증 실패: CSRF 토큰 불일치 또는 세션 만료</h1>");
        return;
    }
    
    String accessToken = "";
    
    // 1. 액세스 토큰 요청 API URL
    String tokenApiURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code"
        + "&client_id=" + clientId
        + "&client_secret=" + clientSecret
        + "&redirect_uri=" + redirectURI
        + "&code=" + code
        + "&state=" + state;

    try {
        // --- 1. 액세스 토큰 요청 및 응답 받기 ---
        URL url = new URL(tokenApiURL);
        HttpURLConnection con = (HttpURLConnection)url.openConnection();
        con.setRequestMethod("GET");
        int responseCode = con.getResponseCode();
        
        InputStream is = (responseCode == 200) ? con.getInputStream() : con.getErrorStream();
        BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        
        StringBuilder res = new StringBuilder();
        String inputLine;
        while ((inputLine = br.readLine()) != null) {
            res.append(inputLine);
        }
        br.close();
        
        if (responseCode == 200) {
            // 응답을 JSON 파싱
            JSONParser parser = new JSONParser();
            JSONObject jsonObject = (JSONObject) parser.parse(res.toString());
            accessToken = (String) jsonObject.get("access_token");
            
            // --- 2. 액세스 토큰을 이용해 사용자 정보(프로필) 요청 ---
            String profileApiURL = "https://openapi.naver.com/v1/nid/me";
            url = new URL(profileApiURL);
            con = (HttpURLConnection)url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Authorization", "Bearer " + accessToken);
            
            responseCode = con.getResponseCode();
            
            is = (responseCode == 200) ? con.getInputStream() : con.getErrorStream();
            br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
            
            res = new StringBuilder();
            while ((inputLine = br.readLine()) != null) {
                res.append(inputLine);
            }
            br.close();
            
            if (responseCode == 200) {
                // 사용자 정보 JSON 파싱
                jsonObject = (JSONObject) parser.parse(res.toString());
                JSONObject responseObj = (JSONObject) jsonObject.get("response");
                
                String naverId = (String) responseObj.get("id"); // 네이버 고유 ID
                String email = (String) responseObj.get("email");
                String name = (String) responseObj.get("name");
                
                // --- 3. 로그인 처리 및 리다이렉션 ---
                
                // 세션에 로그인 정보 저장: 'userId'를 통해 로그인 상태를 확인하도록 통일
                session.setAttribute("naverId", naverId);
                session.setAttribute("userName", name);
                session.setAttribute("userEmail", email);
                
                // ✅ 이 부분이 핵심: 애플리케이션 공통 로그인 키 설정
                session.setAttribute("userId", naverId); 
                
                // 메인 페이지로 리다이렉션
                response.sendRedirect("main_page.jsp"); 
                
            } else {
                out.println("<h1>프로필 조회 오류: HTTP " + responseCode + "</h1>" + res.toString());
            }
        } else {
            out.println("<h1>토큰 요청 오류: HTTP " + responseCode + "</h1>" + res.toString());
        }
    } catch (Exception e) {
        out.println("<h1>예외 발생</h1><pre>" + e.getMessage() + "</pre>");
    }
  %>
  </body>
</html>