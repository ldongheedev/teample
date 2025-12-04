<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. 권한 체크
    String userId = (String) session.getAttribute("userId");
    String isAdmin = (String) session.getAttribute("isAdmin");
    
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    
    int inquiryId = Integer.parseInt(idStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 2. 작성자 확인 (내 글인지, 아니면 관리자인지)
        String checkSql = "SELECT user_id FROM Inquiry WHERE inquiry_id = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, inquiryId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String writerId = rs.getString("user_id");
            
            // 관리자("true") 이거나, 작성자 본인일 경우 삭제 진행
            if ("true".equals(isAdmin) || userId.equals(writerId)) {
                
                // 삭제 쿼리 실행
                pstmt.close();
                String deleteSql = "DELETE FROM Inquiry WHERE inquiry_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setInt(1, inquiryId);
                pstmt.executeUpdate();
                
                // 성공 알림 (누가 삭제했는지에 따라 메시지 다르게)
                String msg = "true".equals(isAdmin) ? "관리자 권한으로 삭제되었습니다." : "문의가 삭제되었습니다.";
%>
                <script>
                    alert("<%= msg %>");
                    location.href = "customer?cmd=inquiryList";
                </script>
<%
            } else {
                out.println("<script>alert('삭제 권한이 없습니다.'); history.back();</script>");
            }
        } else {
            out.println("<script>alert('존재하지 않는 게시글입니다.'); history.back();</script>");
        }

    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close();
    }
%>