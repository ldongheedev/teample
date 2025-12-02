<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 세션에서 관리자 여부 확인
    String footerIsAdmin = (String) session.getAttribute("isAdmin");
%>

<style>
    footer {
        background-color: #f1f1f1;
        padding: 40px;
        display: flex;
        justify-content: space-between;
        /* 수직 정렬을 위쪽(start) 기준으로 변경 */
        align-items: flex-start; 
        font-size: 14px;
        color: #555;
        margin-top: 50px;
    }
    
    .footer-section {
        display: flex;
        flex-direction: column;
        /* 내용물도 위쪽부터 차례대로 쌓이게 변경 */
        justify-content: flex-start;
    }
    
    /* 로고 이미지 크기 제한 */
    .footer-logo {
        height: 80px; 
        width: 200px; 
        object-fit: contain;
        float: left; 
        margin-bottom: 10px;
    }

    .footer-section h4 {
        margin-bottom: 15px;
        font-weight: bold;
        color: #333;
        font-size: 16px;
    }
    
    .footer-section p, 
    .footer-section a {
        margin: 3px 0;
        text-decoration: none;
        color: #555;
        line-height: 1.6;
    }
    
    .footer-section a:hover {
        text-decoration: underline;
    }
    
    /* ✨ [수정됨] 관리자 링크 색상 변경 (파란색 -> 회색) */
    .admin-link {
        font-weight: bold;
        color: #555 !important; /* 회색으로 변경 */
        margin-top: 10px;
        display: inline-block;
    }
    
    /* 오른쪽 링크들 컨테이너 */
    .footer-right {
        display: flex; 
        gap: 60px;
    }
</style>

<footer>
    <div class="footer-section">
        <img src="<%= request.getContextPath() %>/images/logo2.png" alt="하단로고" class="footer-logo">
        <div style="clear:both;"></div>
        <p>(주) 중고모아 | 대표 김령균</p>
        <p>TEL : 010-0000-0000 | Mail : junggomoa@gmail.com</p>
        <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
        <p>이용약관 / 개인정보처리방침</p>
    </div>

    <div class="footer-right">
        <div class="footer-section">
            <h4>ABOUT</h4>
            <a href="company_intro.jsp">회사소개</a>
            <a href="customer?cmd=noticeList">공지사항</a>
        </div>
        <div class="footer-section">
            <h4>SUPPORT</h4>
            <a href="customer?cmd=inquiryList">1:1 문의</a>
            <a href="faq_list.jsp">FAQ</a>
            
            <% if (footerIsAdmin != null && footerIsAdmin.equals("true")) { %>
                <br>
                <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
            <% } %>
        </div>
    </div>
</footer>