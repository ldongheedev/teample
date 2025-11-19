<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String userName = (String) session.getAttribute("userName");
    
    // 관리자 권한이 없으면 접근 차단
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("공지사항 등록은 관리자만 가능합니다.");
            location.href = "main_page.jsp"; 
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 등록</title>
    
    <style>
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

        /* 폼을 감싸는 컨테이너 */
        .notice-form-container {
            width: 700px;
            background-color: #ffffff;
            border: 1px solid #ccc;
            padding: 30px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            border-radius: 8px;
        }

        h2 {
            text-align: center;
            font-size: 26px;
            font-weight: 700;
            color: #2c7be5; /* 제목 색상 */
            margin-bottom: 30px;
            border-bottom: 2px solid #2c7be5;
            padding-bottom: 10px;
        }

        /* 입력 필드 테이블 스타일 */
        .notice-form table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        .notice-form th, 
        .notice-form td {
            padding: 12px;
            border-bottom: 1px solid #eee;
            text-align: left;
        }

        .notice-form th {
            width: 120px;
            background-color: #f7f7f7;
            font-weight: 500;
            color: #555;
            vertical-align: top; /* 내용 상단 정렬 */
        }

        /* 입력 필드 기본 스타일 */
        .notice-form input[type="text"],
        .notice-form textarea {
            width: calc(100% - 20px); /* 패딩 고려 */
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 15px;
            box-sizing: border-box; /* 패딩이 너비에 포함되도록 설정 */
            resize: vertical; /* textarea만 세로 크기 조절 가능 */
        }

        .notice-form textarea {
            min-height: 300px; /* 공지사항 내용은 넓게 */
        }

        /* 버튼 영역 */
        .button-area {
            text-align: center;
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 15px;
        }

        .button-area input[type="button"],
        .button-area input[type="submit"] {
            padding: 12px 25px;
            font-size: 16px;
            font-weight: 700;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        /* 취소 버튼 스타일 */
        .button-area input[type="button"] {
            background-color: #6c757d; /* 회색 */
            color: white;
        }
        .button-area input[type="button"]:hover {
            background-color: #5a6268;
        }

        /* 등록 버튼 스타일 */
        .button-area input[type="submit"] {
            background-color: #2c7be5; /* 메인 색상 (파란색) */
            color: white;
        }
        .button-area input[type="submit"]:hover {
            background-color: #256bc7;
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
    <h2>공지사항 등록</h2>
    
    <form name="noticeForm" action="notice_add_action.jsp" method="post" onsubmit="return validateForm()">
        <div class="notice-form">
            <table>
                <tr>
                    <th>작성자</th>
                    <td>
                        <%= userName %> (<%= session.getAttribute("userId") %>)
                        <input type="hidden" name="writer_id" value="<%= session.getAttribute("userId") %>">
                    </td>
                </tr>
                <tr>
                    <th>제목</th>
                    <td>
                        <input type="text" name="title" placeholder="공지사항 제목을 입력하세요" required>
                    </td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td>
                        <textarea name="content" placeholder="공지사항 내용을 입력하세요" required></textarea>
                    </td>
                </tr>
            </table>    
        </div>
        
        <div class="button-area">
            <input type="button" value="취소" onclick="location.href='notice_list.jsp'"> 
            <input type="submit" value="등록"> 
        </div>
    </form>
</div>

</body>
</html>