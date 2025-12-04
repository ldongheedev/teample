<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    String idStr = request.getParameter("inquiry_id");
    String category = request.getParameter("category");
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    int inquiryId = Integer.parseInt(idStr);
    
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 본인 글 확인 및 업데이트
        String sql = "UPDATE Inquiry SET category=?, title=?, content=? WHERE inquiry_id=? AND user_id=? AND status='WAITING'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, category);
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        pstmt.setInt(4, inquiryId);
        pstmt.setString(5, userId);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            session.setAttribute("toastMessage", "문의 내용이 수정되었습니다.");
            response.sendRedirect("inquiry_detail.jsp?id=" + inquiryId);
        } else {
            out.println("<script>alert('수정에 실패했습니다. 답변이 완료되었거나 본인 글이 아닐 수 있습니다.'); history.back();</script>");
        }

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close();
    }
%>