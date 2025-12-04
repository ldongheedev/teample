<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="dto.InquiryDTO" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 데이터 받기
    InquiryDTO inquiry = (InquiryDTO) request.getAttribute("inquiry");
    if (inquiry == null) {
%>
        <script>alert("존재하지 않는 글입니다."); location.href="customer?cmd=inquiryList";</script>
<%
        return;
    }

    String userId = (String) session.getAttribute("userId");
    String isAdminStr = (String) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminStr != null && isAdminStr.equals("true"));
    
    // 2. 권한 체크 (작성자 or 관리자)
    if (!isAdmin && (userId == null || !userId.equals(inquiry.getUserId()))) {
%>
        <script>alert("비공개 글입니다."); location.href="customer?cmd=inquiryList";</script>
<%
        return;
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    // 메시지 띄우기
    String toastMessage = (String) session.getAttribute("toastMessage");
    if (toastMessage != null) session.removeAttribute("toastMessage");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>문의 상세</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        .container { max-width: 800px; margin: 40px auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        
        .q-header { border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 20px; }
        .q-category { display: inline-block; background-color: #eee; padding: 4px 8px; border-radius: 4px; font-size: 13px; margin-bottom: 10px; }
        .q-title { font-size: 24px; font-weight: 700; }
        .q-meta { font-size: 14px; color: #888; margin-top: 10px; display: flex; justify-content: space-between; }
        .q-content { min-height: 200px; padding: 20px 0; font-size: 16px; line-height: 1.6; white-space: pre-wrap; border-bottom: 1px solid #eee; }
        
        .edit-form table { width: 100%; border-collapse: collapse; }
        .edit-form th { width: 80px; padding: 10px 0; text-align: left; }
        .edit-form td { padding: 10px 0; }
        .edit-form input, .edit-form select, .edit-form textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .edit-form textarea { height: 200px; resize: vertical; }

        .answer-section { margin-top: 40px; background-color: #f8f9fa; padding: 30px; border-radius: 8px; }
        .a-title { font-size: 18px; font-weight: 700; margin-bottom: 15px; color: #2c7be5; }
        .a-content { font-size: 15px; line-height: 1.6; white-space: pre-wrap; }
        
        .btn-area { margin-top: 30px; display: flex; justify-content: space-between; }
        .btn-group-right { display: flex; gap: 10px; }
        .btn { padding: 10px 20px; border-radius: 4px; text-decoration: none; font-size: 14px; font-weight: 500; cursor: pointer; border: none; }
        .btn-list { background-color: #6c757d; color: white; }
        .btn-edit { background-color: #2c7be5; color: white; }
        .btn-delete { background-color: #dc3545; color: white; }
        .btn-cancel { background-color: #ddd; color: #333; }
        .btn-save { background-color: #2c7be5; color: white; }
        
        #toast-container { position: fixed; bottom: 30px; right: 30px; z-index: 9999; }
        .toast { background-color: #333; color: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 10px; opacity: 0; transform: translateY(20px); transition: opacity 0.4s, transform 0.4s; }
        .toast.show { opacity: 1; transform: translateY(0); }
    </style>
    
    <script>
        function toggleEditMode() {
            var viewMode = document.getElementById('view-mode');
            var editMode = document.getElementById('edit-mode');
            if (viewMode.style.display === 'none') {
                viewMode.style.display = 'block'; editMode.style.display = 'none';
            } else {
                viewMode.style.display = 'none'; editMode.style.display = 'block';
            }
        }

        function confirmDelete() {
            if(confirm("관리자 권한으로 이 글을 삭제하시겠습니까? (복구 불가)")) {
                location.href = "customer?cmd=inquiryDelete&id=<%= inquiry.getInquiryId() %>";
            }
        }

        window.onload = function() {
            var msg = "<%= (toastMessage != null) ? toastMessage : "" %>";
            if (msg) {
                var c = document.getElementById('toast-container');
                var t = document.createElement('div'); t.className = 'toast'; t.innerText = msg;
                c.appendChild(t);
                setTimeout(() => t.classList.add('show'), 100);
                setTimeout(() => { t.classList.remove('show'); t.remove(); }, 3000);
            }
        }
    </script>
</head>
<body>
    <div id="toast-container"></div>
    <jsp:include page="header.jsp" />

    <div class="container">
        
        <div id="view-mode">
            <div class="q-header">
                <span class="q-category"><%= inquiry.getCategory() %></span>
                <div class="q-title">Q. <%= inquiry.getTitle() %></div>
                <div class="q-meta">
                    <span>등록일: <%= (inquiry.getCreatedAt() != null) ? sdf.format(inquiry.getCreatedAt()) : "-" %></span>
                    <span>작성자: <%= inquiry.getUserId() %></span>
                </div>
            </div>
            
            <div class="q-content"><%= inquiry.getContent() %></div>

            <div class="btn-area">
                <a href="customer?cmd=inquiryList" class="btn btn-list">목록으로</a>
                <div class="btn-group-right">
                    <% 
                        boolean isWriter = (userId != null && userId.equals(inquiry.getUserId()));
                        // 수정: 본인이고 답변이 안 달렸을 때만
                        boolean canEdit = isWriter && !"ANSWERED".equals(inquiry.getStatus());
                    %>
                    
                    <% if (canEdit) { %>
                        <button type="button" onclick="toggleEditMode()" class="btn btn-edit">수정</button>
                    <% } %>
                    
                    <% if (isAdmin) { %>
                        <button onclick="confirmDelete()" class="btn btn-delete">삭제 (관리자)</button>
                    <% } %>
                </div>
            </div>
        </div>

        <div id="edit-mode" style="display:none;">
            <h3 style="border-bottom:2px solid #333; padding-bottom:15px;">문의 내용 수정</h3>
            <form action="customer" method="post" class="edit-form">
                <input type="hidden" name="cmd" value="inquiryUpdate">
                <input type="hidden" name="inquiry_id" value="<%= inquiry.getInquiryId() %>">
                <table>
                    <tr>
                        <th>분류</th>
                        <td>
                            <select name="category">
                                <option value="거래" <%= "거래".equals(inquiry.getCategory())?"selected":"" %>>거래 관련</option>
                                <option value="신고" <%= "신고".equals(inquiry.getCategory())?"selected":"" %>>신고/제재</option>
                                <option value="회원" <%= "회원".equals(inquiry.getCategory())?"selected":"" %>>회원 정보</option>
                                <option value="오류" <%= "오류".equals(inquiry.getCategory())?"selected":"" %>>시스템 오류</option>
                                <option value="기타" <%= "기타".equals(inquiry.getCategory())?"selected":"" %>>기타</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>제목</th>
                        <td><input type="text" name="title" value="<%= inquiry.getTitle() %>" required></td>
                    </tr>
                    <tr>
                        <th>내용</th>
                        <td><textarea name="content" required><%= inquiry.getContent() %></textarea></td>
                    </tr>
                </table>
                <div class="btn-area" style="justify-content: flex-end; gap: 10px;">
                    <button type="button" onclick="toggleEditMode()" class="btn btn-cancel">취소</button>
                    <button type="submit" class="btn btn-save">수정 완료</button>
                </div>
            </form>
        </div>

        <% if (inquiry.getAnswer() != null && !inquiry.getAnswer().isEmpty()) { %>
            <div class="answer-section">
                <div class="a-title">A. 중고모아 관리자 답변</div>
                <div class="a-content"><%= inquiry.getAnswer() %></div>
            </div>
        <% } else if (isAdmin) { %>
            <div class="answer-section">
                <div class="a-title">관리자 답변 등록</div>
                <form action="customer" method="post">
                    <input type="hidden" name="cmd" value="inquiryAnswer">
                    <input type="hidden" name="inquiry_id" value="<%= inquiry.getInquiryId() %>">
                    <textarea name="answer" placeholder="답변 내용을 입력하세요" style="width:100%; height:100px; padding:10px; border:1px solid #ddd;"></textarea>
                    <button type="submit" class="btn btn-save" style="margin-top:10px;">답변 등록</button>
                </form>
            </div>
        <% } %>

    </div>
    <jsp:include page="footer.jsp" />
</body>
</html>