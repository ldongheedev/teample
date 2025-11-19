<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>

<%-- 토스트 메시지 기능을 포함하는 스크립트 블록 --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>처리 중...</title>
    <style>
        /* 토스트 메시지 스타일 */
        #toast-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 9999;
        }
        .toast {
            background-color: #333;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            margin-bottom: 10px;
            opacity: 0;
            transition: opacity 0.5s, transform 0.5s;
            transform: translateY(100%);
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            min-width: 250px;
            font-size: 14px;
        }
        .toast.show {
            opacity: 1;
            transform: translateY(0);
        }
        .toast.error { background-color: #dc3545; }
        .toast.success { background-color: #28a745; }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', (event) => {
            let container = document.getElementById('toast-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toast-container';
                document.body.appendChild(container);
            }
        });

        function showToast(message, type = 'success', duration = 3000) {
            let container = document.getElementById('toast-container');
            if (!container) return;

            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.textContent = message;
            
            container.appendChild(toast);

            setTimeout(() => {
                toast.classList.add('show');
            }, 10);

            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    toast.remove();
                }, 500); 
            }, duration);
        }
    </script>
</head>
<body>
<%
    // 1. (보안) 관리자 세션 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        // 토스트 메시지 출력 후 이동
        out.println("<script>showToast('권한이 없습니다.', 'error', 2000); setTimeout(() => { location.href='notice_list.jsp'; }, 2000);</script>");
        return;
    }

    // 2. 폼 데이터 받기
    String noticeIdStr = request.getParameter("notice_id");
    // UTF-8 인코딩 설정
    request.setCharacterEncoding("UTF-8");
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    if (noticeIdStr == null || noticeIdStr.trim().isEmpty() || title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
        out.println("<script>showToast('필수 입력 항목이 누락되었습니다.', 'error'); history.back();</script>");
        return;
    }

    int notice_id = 0;
    try {
        notice_id = Integer.parseInt(noticeIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>showToast('잘못된 공지사항 번호 형식입니다.', 'error'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 3. 공지사항 수정 쿼리 실행
        String updateSql = "UPDATE Notice SET title = ?, content = ?, reg_date = NOW() WHERE notice_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        
        pstmt.setString(1, title);
        pstmt.setString(2, content);
        pstmt.setInt(3, notice_id);

        int updatedCount = pstmt.executeUpdate();
        
        if (updatedCount > 0) {
            // 성공: 토스트 메시지 출력 후 상세 페이지로 이동 (msg=updated를 전달하여 상세 페이지에서 토스트 메시지 표시)
            out.println("<script>location.href='notice_detail.jsp?notice_id=" + notice_id + "&msg=updated';</script>");
        } else {
            // 실패 (ID가 없는 경우): 토스트 메시지 출력 후 목록으로 이동
            out.println("<script>showToast('수정할 공지사항이 존재하지 않습니다.', 'error', 2000); setTimeout(() => { location.href='notice_list.jsp'; }, 2000);</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        // 오류 발생: 토스트 메시지 출력 후 복귀
        String errorMessage = "공지사항 수정 중 오류가 발생했습니다. 관리자에게 문의하세요.";
        out.println("<script>showToast('" + errorMessage + "', 'error'); history.back();</script>");
    } finally {
        // 4. 자원 정리
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
</body>
</html>