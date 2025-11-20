<%-- (신규 파일) member_check_pw_action.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('세션이 만료되었거나 로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    // 2. 폼에서 입력한 비밀번호 가져오기
    String inputPassword = request.getParameter("password");
    if (inputPassword == null || inputPassword.trim().isEmpty()) {
        out.println("<script>alert('비밀번호를 입력해주세요.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String dbPassword = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        // 3. DB에서 현재 사용자의 비밀번호 조회
        String sql = "SELECT pw FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            dbPassword = rs.getString("pw");
        } else {
            out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); location.href='loginpage.jsp';</script>");
            return;
        }
        
        // 4. 입력된 비밀번호와 DB 비밀번호 비교
        // (DB에 비밀번호가 '1234'처럼 평문으로 저장되어 있음을 가정)
        if (inputPassword.equals(dbPassword)) {
            // 5. 비밀번호 일치!
            // 세션에 "인증 완료" 플래그를 저장
            session.setAttribute("pw_verified", true);
            // 실제 정보 수정 페이지로 이동
            response.sendRedirect("member_update_form.jsp");
            
        } else {
            // 6. 비밀번호 불일치
            out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('처리 중 오류가 발생했습니다: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>