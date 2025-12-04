<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String userName = (String) session.getAttribute("userName");
    String adminId = (String) session.getAttribute("userId");

    if (isAdmin == null || !isAdmin.equals("true")) {
        // 권한 없으면 목록으로
        out.println("<script>location.href='customer?cmd=noticeList';</script>");
        return; 
    }

    // 2. notice_id 파라미터 받기
    String noticeIdStr = request.getParameter("notice_id");
    if (noticeIdStr == null || noticeIdStr.trim().isEmpty()) {
        out.println("<script>history.back();</script>");
        return;
    }
    int notice_id = 0;
    try {
        notice_id = Integer.parseInt(noticeIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>history.back();</script>");
        return;
    }

    // 기존 데이터 조회 (화면 출력을 위해 JSP에서 조회 유지)
    String title = "";
    String content = "";
    boolean found = false;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "SELECT title, content FROM Notice WHERE notice_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, notice_id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content");
            found = true;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    if (!found) {
        out.println("<script>alert('존재하지 않는 공지사항입니다.'); location.href='customer?cmd=noticeList';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 수정</title>
    
    <style>
        /* notice_add_form.jsp와 동일한 스타일 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .notice-form-container {
            width: 700px;
            background-color: #ffffff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            color: #2c7be5;
            font-size: 28px;
            margin-bottom: 30px;
            border-bottom: 2px solid #eee;
            padding-bottom: 15px;
        }

        .notice-form table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .notice-form th, .notice-form td {
            padding: 15px 0;
            border-bottom: 1px solid #eee;
            text-align: left;
        }

        .notice-form th {
            width: 15%;
            background-color: #f5f5f5;
            color: #555;
            font-weight: 700;
            padding-left: 20px;
            vertical-align: top;
        }

        .notice-form td {
            padding-left: 20px;
        }

        .notice-form input[type="text"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 16px;
        }

        .notice-form textarea {
            width: 100%;
            height: 300px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            resize: vertical;
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 16px;
        }

        .button-area {
            text-align: center;
            margin-top: 30px;
        }

        .button-area input[type="button"],
        .button-area input[type="submit"] {
            padding: 10px 25px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            font-weight: 500;
            transition: background-color 0.2s;
        }

        .button-area input[value="취소"] {
            background-color: #6c757d;
            color: white;
            margin-right: 10px;
        }

        .button-area input[value="취소"]:hover {
            background-color: #5a6268;
        }

        .button-area input[value="수정"] {
            background-color: #2c7be5;
            color: white;
        }

        .button-area input[value="수정"]:hover {
            background-color: #205fb9;
        }
        
    </style>

    <script>
        function validateForm() {
            const form = document.noticeForm;
            if (form.title.value.trim() === "") {
                alert("제목을 입력해주세요.");
                form.title.focus();
                return false;
            }
            if (form.content.value.trim() === "") {
                alert("내용을 입력해주세요.");
                form.content.focus();
                return false;
            }
            return true;
        }
    </script>
</head>
<body>

<div class="notice-form-container">
    <h2>공지사항 수정</h2>
    
    <form name="noticeForm" action="customer" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="cmd" value="noticeUpdate">
        <input type="hidden" name="notice_id" value="<%= notice_id %>">
        
        <div class="notice-form">
            <table>
                <tr>
                    <th>작성자</th>
                    <td>
                        <%= userName %> (<%= adminId %>)
                        <input type="hidden" name="writer_id" value="<%= adminId %>">
                    </td>
                </tr>
                <tr>
                    <th>제목</th>
                    <td>
                        <input type="text" name="title" value="<%= title %>" placeholder="공지사항 제목을 입력하세요" required>
                    </td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td>
                        <textarea name="content" placeholder="공지사항 내용을 입력하세요" required><%= content %></textarea>
                    </td>
                </tr>
            </table>    
        </div>
        
        <div class="button-area">
            <input type="button" value="취소" onclick="location.href='customer?cmd=noticeList'"> 
            <input type="submit" value="수정"> 
        </div>
    </form>
</div>

</body>
</html>