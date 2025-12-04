<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*, dto.NoticeDTO, java.text.SimpleDateFormat" %>
<%
    // Controller에서 보내준 데이터 받기
    List<NoticeDTO> noticeList = (List<NoticeDTO>) request.getAttribute("noticeList");
    // 데이터가 없으면 빈 리스트로 초기화 (에러 방지)
    if (noticeList == null) noticeList = new ArrayList<>();
    
    // 세션 정보 가져오기 (관리자 여부 확인용)
    boolean isManager = "true".equals(session.getAttribute("isAdmin"));
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    
    // 정렬 파라미터 유지
    String sort = request.getParameter("sort");
    if(sort == null) sort = "latest";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 목록</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        
        /* 목록 스타일 */
        .notice-container { max-width: 1000px; margin: 40px auto; padding: 20px; background-color: #ffffff; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-radius: 8px; }
        .notice-container h2 { text-align: center; font-size: 28px; color: #2c7be5; margin-bottom: 30px; }
        
        .notice-header-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding: 0 5px; }
        .sort-options select { padding: 8px 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; cursor: pointer; }
        
        .notice-table { width: 100%; border-collapse: collapse; font-size: 15px; }
        .notice-table th, .notice-table td { padding: 15px 10px; border-bottom: 1px solid #eee; text-align: center; }
        .notice-table th { background-color: #f5f5f5; color: #555; font-weight: 700; border-top: 2px solid #2c7be5; }
        .notice-table tbody tr:hover { background-color: #fcfcfc; }
        
        .notice-table td.title { text-align: left; padding-left: 20px; }
        .notice-table td.title a { color: #333; text-decoration: none; font-weight: 500; }
        .notice-table td.title a:hover { text-decoration: underline; color: #2c7be5; }
        
        .notice-table td.management a { color: #2c7be5; text-decoration: none; margin: 0 5px; font-size: 13px; font-weight: 500; }
        .notice-table td.management a:last-child { color: #dc3545; }
        .notice-table td.management a:hover { font-weight: 700; }

        .write-btn-area { text-align: right; margin-top: 20px; }
        .write-btn { background-color: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 5px; text-decoration: none; font-weight: 500; cursor: pointer; transition: background-color 0.2s; }
        .write-btn:hover { background-color: #1e7e34; }
        .no-data { text-align: center; padding: 50px; color: #777; font-size: 16px; }
    </style>
    <script>
        function changeSort() {
            const selectBox = document.getElementById('sortSelect');
            location.href = 'customer?cmd=noticeList&sort=' + selectBox.value;
        }
        function confirmDelete(noticeId) {
            if (confirm("정말로 삭제하시겠습니까?")) {
                location.href = 'customer?cmd=noticeDelete&notice_id=' + noticeId;
            }
            return false;
        }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="notice-container">
        <h2>공지사항</h2>
        
        <div class="notice-header-bar">
            <div class="total-count">총 <%= noticeList.size() %>개</div>
            <div class="sort-options">
                <select id="sortSelect" onchange="changeSort()">
                    <option value="latest" <%= "latest".equals(sort) ? "selected" : "" %>>최신순</option>
                    <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>오래된순</option>
                    <option value="id_desc" <%= "id_desc".equals(sort) ? "selected" : "" %>>ID 역순</option>
                </select>
            </div>
        </div>

        <table class="notice-table">
            <thead>
                <tr>
                    <th style="width: 10%;">번호</th>
                    <th style="width: <%= isManager ? "60%" : "75%" %>;">제목</th> 
                    <th style="width: 15%;">등록일</th>
                    <% if (isManager) { %> <th style="width: 15%;">관리</th> <% } %>
                </tr>
            </thead>
            <tbody>
                <% if (noticeList.isEmpty()) { %>
                    <tr><td colspan="<%= isManager ? "4" : "3" %>" class="no-data">등록된 공지사항이 없습니다.</td></tr>
                <% } else { 
                    int rowNum = 1;
                    for (NoticeDTO notice : noticeList) { 
                %>
                    <tr>
                        <td><%= rowNum++ %></td>
                        <td class="title">
                            <a href="customer?cmd=noticeDetail&id=<%= notice.getNoticeId() %>">
                                <%= notice.getTitle() %>
                            </a>
                        </td>
                        <td><%= sdf.format(notice.getRegDate()) %></td>
                        <% if (isManager) { %>
                            <td class="management">
                                <a href="notice_update_form.jsp?notice_id=<%= notice.getNoticeId() %>">수정</a>
                                <a href="#" onclick="return confirmDelete(<%= notice.getNoticeId() %>)">삭제</a>
                            </td>
                        <% } %>
                    </tr>
                <% } } %>
            </tbody>
        </table>
        
        <% if (isManager) { %>
            <div class="write-btn-area">
                <a href="notice_add_form.jsp" class="write-btn">공지사항 작성</a>
            </div>
        <% } %>
    </div>
    
    <jsp:include page="footer.jsp" />
</body>
</html>