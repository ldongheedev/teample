<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("loginpage.jsp");
        return;
    }

    String currentPw = request.getParameter("current_pw");
    String newPw = request.getParameter("new_pw");
    String newPwConfirm = request.getParameter("new_pw_confirm");
    
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String addrZip = request.getParameter("addr_zip");
    String addrBase = request.getParameter("addr_base");
    String addrDetail = request.getParameter("addr_detail");

    if (currentPw == null || currentPw.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        phone == null || phone.trim().isEmpty()) {
%>
        <script>
            alert("필수 입력 항목(현재 비밀번호, 이메일, 전화번호)이 비어있습니다.");
            history.back();
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        String dbPw = null;
        String sqlCheck = "SELECT pw FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(sqlCheck);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            dbPw = rs.getString("pw");
        }
        
        rs.close();
        pstmt.close();

        if (dbPw == null || !dbPw.equals(currentPw)) {
%>
            <script>
                alert("현재 비밀번호가 일치하지 않습니다.");
                history.back();
            </script>
<%
            return;
        }
        
        boolean updatePw = false;
        if (newPw != null && !newPw.isEmpty()) {
            if (!newPw.equals(newPwConfirm)) {
%>
                <script>
                    alert("새 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                    history.back();
                </script>
<%
                return;
            }
            updatePw = true;
        }

        StringBuilder sqlUpdate = new StringBuilder("UPDATE member SET ");
        sqlUpdate.append("email = ?, phone = ?, addr_zip = ?, addr_base = ?, addr_detail = ? ");
        
        if (updatePw) {
            sqlUpdate.append(", pw = ? ");
        }
        
        sqlUpdate.append("WHERE id = ?");

        pstmt = conn.prepareStatement(sqlUpdate.toString());
        
        int paramIndex = 1;
        pstmt.setString(paramIndex++, email);
        pstmt.setString(paramIndex++, phone);
        pstmt.setString(paramIndex++, addrZip);
        pstmt.setString(paramIndex++, addrBase);
        pstmt.setString(paramIndex++, addrDetail);
        
        if (updatePw) {
            pstmt.setString(paramIndex++, newPw);
        }
        
        pstmt.setString(paramIndex++, userId);
        
        pstmt.executeUpdate();

        session.setAttribute("toastMessage", "회원 정보가 성공적으로 수정되었습니다.");
        response.sendRedirect("mypage.jsp");

    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("회원정보 수정 중 오류가 발생했습니다: <%= e.getMessage().replace("'", "\\'") %>");
            history.back();
        </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>