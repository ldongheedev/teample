<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String isAdminStr = (String) session.getAttribute("isAdmin");
    if (isAdminStr == null || !isAdminStr.equals("true")) {
        out.println("<script>alert('관리자 권한이 없습니다.'); location.href='inquiry_list.jsp';</script>");
        return;
    }

    String inquiryIdStr = request.getParameter("inquiry_id");
    String answer = request.getParameter("answer");

    if (inquiryIdStr == null || answer == null || answer.trim().isEmpty()) {
        out.println("<script>alert('답변 내용을 입력해주세요.'); history.back();</script>");
        return;
    }

    int inquiryId = Integer.parseInt(inquiryIdStr);
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "UPDATE Inquiry SET answer = ?, status = 'ANSWERED', answered_at = NOW() WHERE inquiry_id = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, answer);
        pstmt.setInt(2, inquiryId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            // ✨ [수정] alert 대신 세션에 메시지 저장 후 리다이렉트
            session.setAttribute("toastMessage", "답변이 성공적으로 등록되었습니다.");
            response.sendRedirect("inquiry_list.jsp");
        } else {
            out.println("<script>alert('답변 등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>