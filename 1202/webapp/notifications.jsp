<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*, dto.TradeDTO, java.text.SimpleDateFormat" %>
<%
    // Controller에서 데이터 받기
    List<TradeDTO> receivedList = (List<TradeDTO>) request.getAttribute("receivedList");
    List<TradeDTO> sentList = (List<TradeDTO>) request.getAttribute("sentList");
    
    if(receivedList == null) receivedList = new ArrayList<>();
    if(sentList == null) sentList = new ArrayList<>();
    
    SimpleDateFormat sdf = new SimpleDateFormat("MM월 dd일 HH:mm");
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 - 알림</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        
        .notification-container { max-width: 900px; margin: 40px auto; padding: 20px 40px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); min-height: 500px; }
        .notification-container h2 { font-size: 24px; margin-bottom: 25px; border-bottom: 2px solid #333; padding-bottom: 10px; }
        
        .notification-list { list-style: none; padding: 0; margin: 0; }
        .notification-item { display: flex; align-items: center; justify-content: space-between; padding: 20px 10px; border-bottom: 1px solid #eee; transition: background-color 0.2s; }
        .notification-item:hover { background-color: #f9f9f9; }
        
        .notification-icon { font-size: 24px; margin-right: 20px; flex-shrink: 0; }
        .notification-content { flex-grow: 1; }
        .message { font-size: 16px; color: #333; font-weight: 500; }
        .highlight { color: #81c147; font-weight: 700; }
        .highlight-red { color: #d9534f; font-weight: 700; }
        .contact-info { color: #2c7be5; font-weight: 700; font-size: 15px; margin-top: 5px; }
        .timestamp { font-size: 14px; color: #888; margin-top: 5px; }
        
        .notification-item.type-chat .notification-icon::before { content: '💬'; }
        .notification-item.type-result .notification-icon::before { content: '📈'; }
        
        .no-notifications { text-align: center; padding: 50px 0; color: #888; font-size: 16px; }
        
        .notification-actions { display: flex; gap: 10px; margin-left: 20px; }
        .btn { padding: 8px 15px; font-size: 14px; font-weight: 500; border: none; border-radius: 5px; cursor: pointer; color: white; }
        .btn-accept { background-color: #81c147; }
        .btn-reject { background-color: #a0a0a0; }

        /* ⚠️ [중요] 여기에 있던 footer 관련 스타일을 모두 지웠습니다!
           이제 footer.jsp 안에 있는 스타일이 적용되어 깔끔하게 나옵니다.
        */
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="notification-container">
        <h2>새로운 거래 요청 (판매자)</h2>
        <ul class="notification-list">
            <% if (receivedList.isEmpty()) { %>
                <li class="no-notifications">새로운 거래 요청이 없습니다.</li>
            <% } else { 
                for(TradeDTO t : receivedList) { %>
                <li class="notification-item type-chat">
                    <div class="notification-icon"></div>
                    <div class="notification-content">
                        <div class="message">
                            <span class="highlight"><%= t.getOtherNickname() %></span>님이
                            '<span class="highlight"><%= t.getProductName() %></span>' 상품에 대해 거래 요청을 보냈습니다.
                        </div>
                        <div class="timestamp"><%= sdf.format(t.getRequestedAt()) %></div>
                    </div>
                    <div class="notification-actions">
                        <button class="btn btn-accept" onclick="location.href='trade?cmd=decide&decision=ACCEPTED&trade_id=<%= t.getTradeId() %>'">수락</button>
                        <button class="btn btn-reject" onclick="location.href='trade?cmd=decide&decision=REJECTED&trade_id=<%= t.getTradeId() %>'">거절</button>
                    </div>
                </li>
            <% } } %>
        </ul>
        
        <h2 style="margin-top: 40px;">내 요청 결과 (구매자)</h2>
        <ul class="notification-list">
            <% if (sentList.isEmpty()) { %>
                <li class="no-notifications">처리된 요청 결과가 없습니다.</li>
            <% } else { 
                for(TradeDTO t : sentList) { 
                    // 대기 중인 요청은 제외하고 결과만 표시
                    if("REQUESTED".equals(t.getStatus())) continue;
            %>
                <li class="notification-item type-result">
                    <div class="notification-icon"></div>
                    <div class="notification-content">
                        <% if ("ACCEPTED".equals(t.getStatus())) { %>
                            <div class="message">
                                <span class="highlight"><%= t.getOtherNickname() %></span>님이
                                '<span class="highlight"><%= t.getProductName() %></span>' 거래를 수락했습니다.
                                <div class="contact-info">판매자 연락처: <%= t.getOtherPhone() %></div>
                            </div>
                        <% } else if ("REJECTED".equals(t.getStatus())) { %>
                            <div class="message">
                                <span class="highlight-red"><%= t.getOtherNickname() %></span>님이
                                '<span class="highlight-red"><%= t.getProductName() %></span>' 거래를 거절했습니다.
                                <div class="timestamp" style="color: #d9534f;">거래가 성립되지 않았습니다.</div>
                            </div>
                        <% } else if ("COMPLETED".equals(t.getStatus())) { %>
                             <div class="message">
                                '<span class="highlight"><%= t.getProductName() %></span>' 거래가 완료되었습니다.
                            </div>
                        <% } %>
                        <div class="timestamp"><%= (t.getAcceptedAt() != null) ? sdf.format(t.getAcceptedAt()) : "-" %></div>
                    </div>
                </li>
            <% } } %>
        </ul>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>