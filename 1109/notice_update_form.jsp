<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String userName = (String) session.getAttribute("userName"); // 작성자 이름 가져오기
    String adminId = (String) session.getAttribute("userId"); // 관리자 ID 가져오기

    if (isAdmin == null || !isAdmin.equals("true")) {
        // 스크립트에서 토스트 호출 후 이동
        out.println("<script>location.href='notice_list.jsp';</script>"); 
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

    // 공지사항 상세 정보를 담을 변수
    String title = "";
    String content = "";
    boolean found = false;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 3. 공지사항 상세 정보 조회 
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

    // 4. 공지사항이 존재하지 않으면 목록으로 이동
    if (!found) {
        out.println("<script>alert('존재하지 않는 공지사항입니다.'); location.href='notice_list.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 수정</title>
    
    <style>
        /* ============================================== */
        /* ✨ notice_add_form.jsp의 CSS를 그대로 복사 적용 */
        /* ============================================== */
        /* 웹폰트 - Noto Sans KR (main_page.jsp 등과 동일) */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');

        /* 전체 페이지 레이아웃 및 폰트 설정 */
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

        /* 폼 컨테이너 */
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

        /* 폼 내부 테이블 스타일 */
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
            vertical-align: top; /* 작성자/내용 필드가 길어질 때 정렬 */
        }

        .notice-form td {
            padding-left: 20px;
        }

        /* 입력 필드 스타일 */
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
            height: 300px; /* 내용 필드 높이 */
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            resize: vertical; /* 수직 크기 조절 허용 */
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 16px;
        }

        /* 버튼 영역 */
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

        .button-area input[value="등록"],
        .button-area input[value="수정"] {
            background-color: #2c7be5; /* 메인 색상 */
            color: white;
        }

        .button-area input[value="등록"]:hover,
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
    
    <form name="noticeForm" action="notice_update_action.jsp" method="post" onsubmit="return validateForm()">
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
            <input type="button" value="취소" onclick="location.href='notice_list.jsp'"> 
            <input type="submit" value="수정"> 
        </div>
    </form>
</div>

</body>
</html>