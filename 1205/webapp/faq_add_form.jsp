<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("접근 권한이 없습니다.");
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
    <title>FAQ 등록</title>
    
    <style>
        /* (notice_add_form.jsp와 동일한 스타일 사용) */
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
        .faq-form-container {
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
            color: #2c7be5; 
            margin-bottom: 30px;
            border-bottom: 2px solid #2c7be5;
            padding-bottom: 10px;
        }
        .faq-form table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .faq-form th, .faq-form td {
            padding: 12px;
            border-bottom: 1px solid #eee;
            text-align: left;
        }
        .faq-form th {
            width: 120px;
            background-color: #f7f7f7;
            font-weight: 500;
            color: #555;
            vertical-align: top;
        }
        .faq-form input[type="text"],
        .faq-form select,
        .faq-form textarea {
            width: calc(100% - 20px); 
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 15px;
            box-sizing: border-box; 
            resize: vertical; 
        }
        .faq-form textarea {
            min-height: 300px; 
        }
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
        .button-area input[type="button"] {
            background-color: #6c757d; 
            color: white;
        }
        .button-area input[type="button"]:hover {
            background-color: #5a6268;
        }
        .button-area input[type="submit"] {
            background-color: #2c7be5; 
            color: white;
        }
        .button-area input[type="submit"]:hover {
            background-color: #256bc7;
        }
    </style>
    
    <script>
        function validateForm() {
            const form = document.faqForm;
            if (form.category.value === "") {
                alert("분류를 선택해주세요.");
                form.category.focus();
                return false;
            }
            if (form.question.value.trim() === "") {
                alert("질문을 입력해주세요.");
                form.question.focus();
                return false;
            }
            if (form.answer.value.trim() === "") {
                alert("답변을 입력해주세요.");
                form.answer.focus();
                return false;
            }
            return true;
        }
    </script>
</head>
<body>

<div class="faq-form-container">
    <h2>FAQ 등록</h2>
    
    <form name="faqForm" action="faq_add_action.jsp" method="post" onsubmit="return validateForm()">
        <div class="faq-form">
            <table>
                <tr>
                    <th>분류</th>
                    <td>
                        <select name="category" required>
                            <option value="">-- 분류 선택 --</option>
                            <option value="주문">주문/결제</option>
                            <option value="회원정보">회원정보</option>
                            <option value="기타">기타</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>질문(제목)</th>
                    <td>
                        <input type="text" name="question" placeholder="질문을 입력하세요" required>
                    </td>
                </tr>
                <tr>
                    <th>답변(내용)</th>
                    <td>
                        <textarea name="answer" placeholder="답변을 입력하세요" required></textarea>
                    </td>
                </tr>
            </table>    
        </div>
        
        <div class="button-area">
            <input type="button" value="취소" onclick="location.href='faq_admin_list.jsp'"> 
            <input type="submit" value="등록"> 
        </div>
    </form>
</div>

</body>
</html>