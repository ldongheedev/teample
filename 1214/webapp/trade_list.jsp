<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*, dto.TradeDTO" %>
<%
    // Controller에서 데이터 받기
    List<TradeDTO> tradeList = (List<TradeDTO>) request.getAttribute("tradeList");
    if(tradeList == null) tradeList = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>거래 조회</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        .mypage-wrapper { display: flex; max-width: 1400px; min-height: 70vh; margin: 20px auto; gap: 20px; }
        .mypage-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; height: fit-content; }
        .mypage-sidebar h3 { font-size: 18px; color: #333; margin-top: 0; margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .mypage-sidebar ul { list-style: none; padding: 0; margin: 0 0 20px 0; }
        .mypage-sidebar li a { display: block; padding: 12px 15px; text-decoration: none; color: #555; font-size: 15px; border-radius: 6px; }
        .mypage-sidebar li a:hover { background-color: #f5f5f5; }
        .mypage-sidebar li.active a { background-color: #81c147; color: white; font-weight: 500; }
        .mypage-content { flex-grow: 1; background-color: #ffffff; padding: 30px 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        
        .trade-list { list-style: none; padding: 0; margin: 0; }
        .trade-item { display: flex; align-items: center; padding: 15px; border: 1px solid #eee; border-radius: 8px; margin-bottom: 15px; }
        .trade-item img { width: 80px; height: 80px; background-color: #e0e0e0; border-radius: 6px; margin-right: 20px; object-fit: cover; }
        .trade-info { flex-grow: 1; }
        .status-tag { padding: 5px 10px; border-radius: 5px; font-weight: 700; font-size: 13px; display: inline-block; }
        
        .status-requested { background-color: #f0f0f0; color: #888; }
        .status-accepted { background-color: #eaf6e1; color: #81c147; }
        .status-rejected { background-color: #fbeae9; color: #d9534f; }
        .status-completed { background-color: #e9ecef; color: #495057; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />
    
    <div class="mypage-wrapper">
        <nav class="mypage-sidebar">
            <h3>회원정보</h3>
            <ul>
                <li><a href="member_check_pw_form.jsp">정보 수정</a></li>
                <li><a href="member_delete_form.jsp">회원 탈퇴</a></li> 
            </ul>
            
            <h3>쇼핑정보</h3>
            <ul>
                <li><a href="wishlist.jsp">찜리스트</a></li>
                <li class="active"><a href="trade?cmd=list">거래조회</a></li>
            </ul>
            
            <h3>상품관리</h3>
            <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
            
            <h3>고객센터</h3>
            <ul>
                <li><a href="customer?cmd=inquiryList">1:1 문의</a></li>
                <li><a href="faq_list.jsp">FAQ</a></li>
            </ul>
        </nav>
        
        <main class="mypage-content">
            <h2>거래조회 (내가 구매 요청한 내역)</h2>
            <ul class="trade-list">
                <% if (tradeList.isEmpty()) { %>
                    <li style="text-align:center; padding:50px; color:#888;">거래 요청한 내역이 없습니다.</li>
                <% } else { 
                    for(TradeDTO t : tradeList) {
                        String statusClass = "status-requested";
                        String statusText = "대기중";
                        if("ACCEPTED".equals(t.getStatus())) { statusClass="status-accepted"; statusText="수락됨"; }
                        else if("REJECTED".equals(t.getStatus())) { statusClass="status-rejected"; statusText="거절됨"; }
                        else if("COMPLETED".equals(t.getStatus())) { statusClass="status-completed"; statusText="거래완료"; }
                        
                        String img = (t.getMainImageUrl() != null && !t.getMainImageUrl().isEmpty()) ? 
                                     request.getContextPath() + t.getMainImageUrl() : request.getContextPath()+"/images/logo.png";
                %>
                    <li class="trade-item">
                        <img src="<%= img %>" alt="상품이미지">
                        <div class="trade-info">
                            <div style="font-weight:bold; font-size:16px;"><%= t.getProductName() %></div>
                            <div style="color:#666; font-size:13px; margin-top:5px;">판매자: <%= t.getOtherNickname() %></div>
                        </div>
                        <div>
                            <span class="status-tag <%= statusClass %>"><%= statusText %></span>
                        </div>
                    </li>
                <% } } %>
            </ul>
        </main>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>