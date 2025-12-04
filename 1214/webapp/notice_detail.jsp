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
        
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }

        .notice-container { max-width: 800px; margin: 40px auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .notice-title { font-size: 24px; font-weight: bold; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 20px; }
        .notice-info { display: flex; justify-content: space-between; color: #666; font-size: 14px; border-bottom: 1px solid #eee; padding-bottom: 20px; margin-bottom: 30px; }
        
        /* ✨ [수정] 내용 스타일: 줄바꿈 유지 + 불필요한 여백 제거 */
        .notice-content { 
            min-height: 300px; 
            line-height: 1.8; 
            font-size: 16px; 
            white-space: pre-wrap; /* 줄바꿈 유지 */
            word-break: break-all; /* 긴 단어 줄바꿈 */
        }

        .detail-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 40px; border-top: 1px solid #eee; padding-top: 20px; }
        .detail-actions a { padding: 10px 20px; border-radius: 4px; font-size: 14px; font-weight: 500; text-decoration: none; color: white; display: inline-block; }
        .list-btn { background-color: #6c757d; }
        .admin-edit-btn { background-color: #2c7be5; }
        .admin-delete-btn { background-color: #dc3545; }
        
        /* Footer (간소화) */
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: center; font-size: 14px; color: #555; margin-top: 50px; }
    </style>
    <script>
        function toggleDropdown() { document.getElementById("myDropdown").classList.toggle("show"); }
        window.onclick = function(event) {
            if (!event.target.matches('.dropdown-toggle')) {
                var dropdowns = document.getElementsByClassName("dropdown-content");
                for (var i = 0; i < dropdowns.length; i++) {
                    var openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) openDropdown.classList.remove('show');
                }
            }
        }
        function confirmDelete(noticeId) {
            if (confirm("정말로 이 공지사항을 삭제하시겠습니까?")) {
                location.href = 'customer?cmd=noticeDelete&notice_id=' + noticeId;
            }
            return false;
        }
    </script>
</head>
<body>
    <header>
        <div class="logo">
            <a href="main_page.jsp"><img src="<%= request.getContextPath() %>/images/logo.png" alt="로고"></a>
        </div>
        <div class="header-links">
            <% if (userId == null) { %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
            <% } else { %>
                <div class="welcome-message"><%= userName %>님, 환영합니다.</div>
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="member?cmd=logout">로그아웃</a>
                    </div>
                </div>
            <% } %>
        </div>
    </header>

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
    
    <footer>
        <p>(주) 중고모아 | 대표 김령균 | 1:1 문의 및 고객센터 운영 중</p>
    </footer>

</body>
</html>