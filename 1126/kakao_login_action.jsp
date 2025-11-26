<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String kakaoId = request.getParameter("kakao_id");
    String nickname = request.getParameter("nickname");
    String email = request.getParameter("email");

    if (kakaoId == null || kakaoId.isEmpty()) {
        out.println("<script>alert('로그인 정보 오류'); location.href='loginpage.jsp';</script>");
        return;
    }

    // 아이디 충돌 방지를 위해 'k_' 접두사 사용
    String dbId = "k_" + kakaoId;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        // 1. 이미 가입된 회원인지 확인
        String checkSql = "SELECT * FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, dbId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // [로그인] 이미 존재함 -> 세션 생성
            session.setAttribute("userId", dbId);
            session.setAttribute("userName", rs.getString("nickname"));
            session.setAttribute("isAdmin", rs.getString("isAdmin"));
            
            response.sendRedirect("main_page.jsp");
        } else {
            // [회원가입] 없음 -> DB Insert 후 로그인
            rs.close(); pstmt.close();

            String insertSql = "INSERT INTO member (id, pw, nickname, email, phone, addr_zip, addr_base, addr_detail, status, isAdmin, warning_count, created_at) VALUES (?, 'kakao_pw', ?, ?, '', '', '', '', 'ACTIVE', 'false', 0, NOW())";
            
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, dbId);
            pstmt.setString(2, nickname); // 카카오 닉네임
            pstmt.setString(3, email != null ? email : "");
            
            int result = pstmt.executeUpdate();

            if (result > 0) {
                session.setAttribute("userId", dbId);
                session.setAttribute("userName", nickname);
                session.setAttribute("isAdmin", "false");
                
                session.setAttribute("toastMessage", "카카오 계정으로 가입되었습니다.");
                response.sendRedirect("main_page.jsp");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage() + "'); location.href='loginpage.jsp';</script>");
    } finally {
        if(rs!=null) try{rs.close();}catch(Exception e){}
        if(pstmt!=null) try{pstmt.close();}catch(Exception e){}
        if(conn!=null) try{conn.close();}catch(Exception e){}
    }
%>