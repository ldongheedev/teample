<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        session.setAttribute("toastMessage", "삭제 권한이 없습니다.");
        response.sendRedirect("faq_list.jsp"); // 권한 없으면 faq_list로
        return;
    }

    // 2. 파라미터 받기
    String faqIdStr = request.getParameter("faq_id");
    String category = request.getParameter("category"); // (신규) 리다이렉트 시 사용할 카테고리
    
    if (category == null || category.isEmpty()) {
        category = "주문"; // 기본값
    }

    int faq_id = 0;
    try {
        faq_id = Integer.parseInt(faqIdStr);
    } catch (NumberFormatException e) {
        session.setAttribute("toastMessage", "오류: 잘못된 FAQ ID입니다.");
        response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String deleteSql = "DELETE FROM Faq WHERE faq_id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, faq_id);

        int deletedCount = pstmt.executeUpdate();
        
        if (deletedCount > 0) {
            // (변경) 성공 시 토스트 메시지 저장
            session.setAttribute("toastMessage", "FAQ가 성공적으로 삭제되었습니다.");
        } else {
            // (변경) 실패 시 토스트 메시지 저장
            session.setAttribute("toastMessage", "오류: FAQ 삭제에 실패했습니다. (ID 불일치)");
        }

    } catch (Exception e) {
        e.printStackTrace();
        // (변경) 예외 발생 시 토스트 메시지 저장
        session.setAttribute("toastMessage", "오류: DB 처리 중 오류가 발생했습니다.");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // (변경) 무조건 faq_list.jsp로 리다이렉트 (카테고리 유지)
    response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
%>