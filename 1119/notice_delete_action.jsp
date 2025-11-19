<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>처리 중...</title>
</head>
<body>
<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        // 권한이 없으므로 목록으로 리다이렉트 (목록 페이지에서 권한 없음 토스트 표시)
        response.sendRedirect("notice_list.jsp");
        return;
    }

    // 2. notice_id 파라미터 받기
    String noticeIdStr = request.getParameter("notice_id");
    if (noticeIdStr == null || noticeIdStr.trim().isEmpty()) {
        response.sendRedirect("notice_list.jsp?msg=delete_error");
        return;
    }

    int notice_id = 0;
    try {
        notice_id = Integer.parseInt(noticeIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("notice_list.jsp?msg=delete_error");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 3. 공지사항 삭제 쿼리 실행
        String deleteSql = "DELETE FROM Notice WHERE notice_id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        
        pstmt.setInt(1, notice_id);

        int deletedCount = pstmt.executeUpdate();
        
        if (deletedCount > 0) {
            // 성공: 목록 페이지로 이동하며 성공 메시지 전달
            response.sendRedirect("notice_list.jsp?msg=deleted");
        } else {
            // 실패 (ID가 없는 경우): 목록 페이지로 이동하며 오류 메시지 전달
            response.sendRedirect("notice_list.jsp?msg=delete_error");
        }

    } catch (Exception e) {
        e.printStackTrace();
        // 오류 발생: 목록 페이지로 이동하며 오류 메시지 전달
        response.sendRedirect("notice_list.jsp?msg=delete_error");
    } finally {
        // 4. 자원 정리
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
</body>
</html>