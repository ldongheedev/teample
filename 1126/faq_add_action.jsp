<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.UnsupportedEncodingException" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // ... (파일 상단의 관리자 체크 및 파라미터 받는 로직은 동일) ...
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        // ... (권한 없음 처리) ...
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String category = request.getParameter("category");
    String question = request.getParameter("question");
    String answer = request.getParameter("answer");
    
    // ... (입력값 null 체크 로직 동일) ...

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "INSERT INTO Faq (category, question, answer) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, category);
        pstmt.setString(2, question);
        pstmt.setString(3, answer);
        
        int count = pstmt.executeUpdate();
        
        if (count > 0) {
            // ✨ (변경) 토스트 메시지 저장
            session.setAttribute("toastMessage", "FAQ가 성공적으로 등록되었습니다.");
            // ✨ (변경) faq_list.jsp로 리다이렉트
            response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
        } else {
            // ... (등록 실패 알림 로직 동일) ...
            session.setAttribute("toastMessage", "오류: FAQ 등록에 실패했습니다.");
            response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        // ... (예외 발생 알림 로직 - 토스트 메시지로 변경) ...
        session.setAttribute("toastMessage", "오류: DB 처리 중 오류가 발생했습니다.");
        response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>