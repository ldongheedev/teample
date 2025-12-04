<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        session.setAttribute("toastMessage", "수정 권한이 없습니다.");
        response.sendRedirect("faq_list.jsp");
        return;
    }

    // 2. 폼 데이터 받기
    request.setCharacterEncoding("UTF-8");
    String faqIdStr = request.getParameter("faq_id");
    String category = request.getParameter("category");
    String question = request.getParameter("question");
    String answer = request.getParameter("answer");
    
    int faq_id = 0;
    try {
        faq_id = Integer.parseInt(faqIdStr);
    } catch (NumberFormatException e) {
        session.setAttribute("toastMessage", "오류: 잘못된 FAQ ID입니다.");
        response.sendRedirect("faq_list.jsp");
        return;
    }

    // 3. 필수 입력값 검증
    if (category == null || category.trim().isEmpty() ||
        question == null || question.trim().isEmpty() || 
        answer == null || answer.trim().isEmpty()) {
        
        session.setAttribute("toastMessage", "오류: 모든 항목을 입력해야 합니다.");
        // 수정 폼으로 다시 돌려보냄
        response.sendRedirect("faq_update_form.jsp?faq_id=" + faq_id);
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 4. FAQ 수정 쿼리 실행
        String updateSql = "UPDATE Faq SET category = ?, question = ?, answer = ? WHERE faq_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        
        pstmt.setString(1, category);
        pstmt.setString(2, question);
        pstmt.setString(3, answer);
        pstmt.setInt(4, faq_id);

        int updatedCount = pstmt.executeUpdate();
        
        if (updatedCount > 0) {
            // 성공: 토스트 메시지 저장 후 목록으로 이동
            session.setAttribute("toastMessage", "FAQ가 성공적으로 수정되었습니다.");
            response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
        } else {
            // 실패: 토스트 메시지 저장 후 목록으로 이동
            session.setAttribute("toastMessage", "오류: FAQ 수정에 실패했습니다 (ID 불일치).");
            response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
        }

    } catch (Exception e) {
        e.printStackTrace();
        // 오류 발생: 토스트 메시지 저장 후 목록으로 이동
        session.setAttribute("toastMessage", "오류: DB 처리 중 오류가 발생했습니다.");
        response.sendRedirect("faq_list.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>