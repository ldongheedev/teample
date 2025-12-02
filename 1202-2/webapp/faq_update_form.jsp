<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        session.setAttribute("toastMessage", "수정 권한이 없습니다.");
        response.sendRedirect("faq_list.jsp");
        return; 
    }

    // 2. faq_id 파라미터 받기
    String faqIdStr = request.getParameter("faq_id");
    if (faqIdStr == null || faqIdStr.trim().isEmpty()) {
        session.setAttribute("toastMessage", "오류: 잘못된 접근입니다.");
        response.sendRedirect("faq_list.jsp");
        return;
    }
    int faq_id = Integer.parseInt(faqIdStr);

    // 3. DB에서 기존 FAQ 정보 조회
    String category = "";
    String question = "";
    String answer = "";
    boolean found = false;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        String sql = "SELECT category, question, answer FROM Faq WHERE faq_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, faq_id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            category = rs.getString("category");
            question = rs.getString("question");
            answer = rs.getString("answer");
            found = true;
        } else {
            session.setAttribute("toastMessage", "오류: 수정할 FAQ를 찾을 수 없습니다.");
            response.sendRedirect("faq_list.jsp");
            return;
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>FAQ 수정</title>
    
    <style>
        /* (faq_add_form.jsp와 동일한 스타일 사용) */
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
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        h2 {
            text-align: center;
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 25px;
        }
        .faq-form table {
            width: 100%;
            border-collapse: collapse;
        }
        .faq-form th, .faq-form td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .faq-form th {
            width: 100px;
            text-align: left;
            background-color: #fcfcfc;
            font-weight: 500;
        }
        .faq-form input[type="text"],
        .faq-form select,
        .faq-form textarea {
            width: 98%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-family: 'Noto Sans KR', sans-serif;
        }
        .faq-form textarea {
            height: 200px;
            resize: vertical;
        }
        .button-area {
            text-align: center;
            margin-top: 30px;
        }
        .button-area input[type="button"],
        .button-area input[type="submit"] {
            padding: 10px 20px;
            font-size: 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 0 5px;
        }
        .button-area input[type="button"] {
            background-color: #6c757d;
            color: white;
        }
        .button-area input[type="submit"] {
            background-color: #007bff;
            color: white;
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
    <h2>FAQ 수정</h2>
    
    <form name="faqForm" action="faq_update_action.jsp" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="faq_id" value="<%= faq_id %>">
        
        <div class="faq-form">
            <table>
                <tr>
                    <th>분류</th>
                    <td>
                        <select name="category" required>
                            <option value="">-- 분류 선택 --</option>
                            <option value="주문" <%= "주문".equals(category) ? "selected" : "" %>>주문/결제</option>
                            <option value="회원정보" <%= "회원정보".equals(category) ? "selected" : "" %>>회원정보</option>
                            <option value="기타" <%= "기타".equals(category) ? "selected" : "" %>>기타</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th>질문(제목)</th>
                    <td>
                        <input type="text" name="question" value="<%= question %>" placeholder="질문을 입력하세요" required>
                    </td>
                </tr>
                <tr>
                    <th>답변(내용)</th>
                    <td>
                        <textarea name="answer" placeholder="답변을 입력하세요" required><%= answer %></textarea>
                    </td>
                </tr>
            </table>    
        </div>
        
        <div class="button-area">
            <input type="button" value="취소" onclick="location.href='faq_list.jsp?category=<%= URLEncoder.encode(category, "UTF-8") %>'"> 
            <input type="submit" value="수정"> 
        </div>
    </form>
</div>

</body>
</html>