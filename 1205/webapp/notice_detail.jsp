<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="dto.NoticeDTO, java.text.SimpleDateFormat" %>
<%
    // ✨ 컨트롤러가 보내준 데이터("notice") 받기
    NoticeDTO notice = (NoticeDTO) request.getAttribute("notice");
    
    // 데이터가 없으면 목록으로 튕겨내기
    if (notice == null) {
%>
        <script>
            alert("존재하지 않거나 삭제된 게시글입니다.");
            location.href = "customer?cmd=noticeList";
        </script>
<%
        return;
    }
    
    String userName = (String) session.getAttribute("userName");
    String userId = (String) session.getAttribute("userId");
    boolean isManager = "true".equals(session.getAttribute("isAdmin"));
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= notice.getTitle() %></title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        /* ... (기존 CSS 코드 복사해서 유지) ... */
        .notice-container { max-width: 800px; margin: 40px auto; padding: 20px; background-color: #ffffff; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-radius: 8px; }
        .notice-title { font-size: 28px; font-weight: 700; color: #333; padding-bottom: 10px; border-bottom: 3px solid #2c7be5; }
        .notice-info { display: flex; justify-content: space-between; font-size: 14px; color: #777; padding: 10px 0; border-bottom: 1px solid #eee; margin-bottom: 30px; }
        .notice-content { font-size: 16px; line-height: 1.8; min-height: 200px; white-space: pre-wrap; padding: 20px 0; }
        .detail-actions { text-align: right; padding-top: 20px; border-top: 1px solid #eee; }
        .detail-actions a { padding: 10px 15px; font-size: 15px; border-radius: 5px; margin-left: 10px; font-weight: 500; text-decoration: none; color: white; display: inline-block; }
        .list-btn { background-color: #6c757d; }
        .admin-edit-btn { background-color: #2c7be5; }
        .admin-delete-btn { background-color: #dc3545; }
    </style>
    <script>
        function confirmDelete(noticeId) {
            if (confirm("정말로 이 공지사항을 삭제하시겠습니까?")) {
                // ✨ 컨트롤러 삭제 요청으로 변경
                location.href = 'customer?cmd=noticeDelete&notice_id=' + noticeId;
            }
            return false;
        }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" /> 

    <div class="notice-container">
        <div class="notice-title"><%= notice.getTitle() %></div>
        
        <div class="notice-info">
            <span>작성자: 관리자</span>
            <span>등록일: <%= sdf.format(notice.getRegDate()) %></span>
            <span>조회수: <%= notice.getViews() %></span>
        </div>
        
        <div class="notice-content"><%= notice.getContent() %></div>

        <div class="detail-actions">
            <a href="customer?cmd=noticeList" class="list-btn">목록으로</a>
            
            <% if (isManager) { %>
                <a href="notice_update_form.jsp?notice_id=<%= notice.getNoticeId() %>" class="admin-edit-btn">수정</a>
                <a href="#" onclick="return confirmDelete(<%= notice.getNoticeId() %>)" class="admin-delete-btn">삭제</a>
            <% } %>
        </div>
    </div>

    <jsp:include page="footer.jsp" /> 
</body>
</html>