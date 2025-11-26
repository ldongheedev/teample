<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 폼 데이터 받기
    String id = request.getParameter("id");
    String pw = request.getParameter("pw");
    String nickname = request.getParameter("nickname");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String addr_zip = request.getParameter("addr_zip");
    String addr_base = request.getParameter("addr_base");
    String addr_detail = request.getParameter("addr_detail");
    
    // 유효성 검사 (간단 체크)
    if(id == null || pw == null || nickname == null || email == null || phone == null) {
%>
        <script>
            alert('필수 입력 항목이 누락되었습니다.');
            history.back();
        </script>
<%
        return;
    }
    
    // ⚠️ 실제 서비스 시 비밀번호는 반드시 해싱(암호화)해야 합니다.
    String encryptedPw = pw; // 임시로 평문 사용
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String errorMessage = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 2. 아이디 중복 확인 (서버 단에서 한 번 더 체크)
        String checkIdSql = "SELECT id FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(checkIdSql);
        pstmt.setString(1, id);
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>
            <script>
                alert('이미 사용 중인 아이디입니다.');
                history.back();
            </script>
<%
            return;
        }
        rs.close();
        pstmt.close();
        
        // 3. 닉네임 중복 확인 (서버 단에서 한 번 더 체크)
        String checkNickSql = "SELECT nickname FROM member WHERE nickname = ?";
        pstmt = conn.prepareStatement(checkNickSql);
        pstmt.setString(1, nickname);
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>
            <script>
                alert('이미 사용 중인 닉네임입니다.');
                history.back();
            </script>
<%
            return;
        }
        rs.close();
        pstmt.close();

        // 4. 회원 정보 INSERT (필수 컬럼 추가)
        // created_at, status, isAdmin, warning_count 등을 명시적으로 추가하여 오류 방지
        String insertSql = "INSERT INTO member " +
                           "(id, pw, nickname, email, phone, addr_zip, addr_base, addr_detail, status, isAdmin, warning_count, created_at) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', 'false', 0, NOW())";
        
        pstmt = conn.prepareStatement(insertSql);
        pstmt.setString(1, id);
        pstmt.setString(2, encryptedPw);
        pstmt.setString(3, nickname);
        pstmt.setString(4, email);
        pstmt.setString(5, phone);
        pstmt.setString(6, addr_zip);
        pstmt.setString(7, addr_base);
        pstmt.setString(8, addr_detail);
        
        int count = pstmt.executeUpdate();
        
        if (count > 0) {
%>
            <script>
                alert('회원가입이 성공적으로 완료되었습니다.');
                // 1. 부모 창(메인 창)을 로그인 페이지로 이동
                if (window.opener && !window.opener.closed) {
                    window.opener.location.href = 'loginpage.jsp';
                }
                // 2. 현재 팝업 창 닫기
                window.close(); 
            </script>
<%
        } else {
%>
            <script>
                alert('회원가입에 실패했습니다. 다시 시도해 주세요.');
                history.back();
            </script>
<%
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        errorMessage = e.getMessage().replace("'", "\\'").replace("\"", "\\\"");
%>
        <script>
            // 오류 발생 시 구체적인 메시지를 띄워줍니다.
            alert('오류 발생: <%= errorMessage %>\n관리자에게 해당 오류 메시지를 전달해주세요.');
            history.back();
        </script>
<%
    } finally {
        // 자원 정리
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
</body>
</html>