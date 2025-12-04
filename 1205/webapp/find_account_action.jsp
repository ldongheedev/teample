<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    String mode = request.getParameter("mode");
    String nickname = request.getParameter("nickname");
    String email = request.getParameter("email");
    String id = request.getParameter("id"); // 비밀번호 찾기일 때만 사용

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    boolean isFound = false;
    String resultText = "";
    String resultLabel = ""; // "아이디" 또는 "비밀번호"

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        // 기존 프로젝트 DB 설정 유지 (포트 3308, jspdb, jsp/1234)
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        if ("find_id".equals(mode)) {
            // 아이디 찾기 로직
            String sql = "SELECT id FROM member WHERE nickname = ? AND email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nickname);
            pstmt.setString(2, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                isFound = true;
                resultLabel = "아이디";
                resultText = rs.getString("id");
            }
        } else if ("find_pw".equals(mode)) {
            // 비밀번호 찾기 로직 (평문 비밀번호 조회)
            String sql = "SELECT pw FROM member WHERE id = ? AND nickname = ? AND email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            pstmt.setString(2, nickname);
            pstmt.setString(3, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                isFound = true;
                resultLabel = "비밀번호";
                resultText = rs.getString("pw");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    
    // 결과 페이지로 데이터 전달
    request.setAttribute("isFound", isFound);
    request.setAttribute("resultLabel", resultLabel);
    request.setAttribute("resultText", resultText);
    
    RequestDispatcher dispatcher = request.getRequestDispatcher("find_account_result.jsp");
    dispatcher.forward(request, response);
%>