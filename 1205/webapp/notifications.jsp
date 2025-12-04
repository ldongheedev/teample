<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*, dto.TradeDTO, dto.NotificationDTO, java.text.SimpleDateFormat" %>
<%
    // 리스트 데이터
    List<TradeDTO> receivedList = (List<TradeDTO>) request.getAttribute("receivedList");
    List<TradeDTO> sentList = (List<TradeDTO>) request.getAttribute("sentList");
    List<NotificationDTO> notiList = (List<NotificationDTO>) request.getAttribute("generalList");
    
    if(receivedList == null) receivedList = new ArrayList<>();
    if(sentList == null) sentList = new ArrayList<>();
    if(notiList == null) notiList = new ArrayList<>();
    
    // 페이징 데이터
    int tradePage = (Integer) request.getAttribute("tradePage");
    int totalTradePages = (Integer) request.getAttribute("totalTradePages");
    
    int notiPage = (Integer) request.getAttribute("notiPage");
    int totalNotiPages = (Integer) request.getAttribute("totalNotiPages");

    SimpleDateFormat sdf = new SimpleDateFormat("MM월 dd일 HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>알림 센터</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        
        .notification-container { max-width: 900px; margin: 40px auto; padding: 30px 40px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); min-height: 600px; }
        
        h2 { font-size: 20px; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #333; margin-top: 40px; }
        h2:first-child { margin-top: 0; }
        .badge-count { background: #e03131; color: white; padding: 2px 8px; border-radius: 12px; font-size: 14px; vertical-align: middle; margin-left: 5px; }

        .noti-list { list-style: none; padding: 0; margin: 0; }
        .noti-item { display: flex; align-items: flex-start; padding: 20px 10px; border-bottom: 1px solid #eee; transition: background-color 0.2s; }
        .noti-item:hover { background-color: #f9f9f9; }
        
        .noti-icon { font-size: 24px; margin-right: 15px; width: 30px; text-align: center; padding-top: 2px; }
        .noti-content { flex-grow: 1; }
        .noti-msg { font-size: 15px; color: #333; line-height: 1.5; }
        .noti-date { font-size: 13px; color: #999; margin-top: 6px; }
        
        .type-INQUIRY .noti-icon::before { content: '💬'; } 
        .type-WARNING .noti-icon::before { content: '🚨'; } 
        .type-DELETE .noti-icon::before { content: '🗑️'; }  
        .type-TRADE .noti-icon::before { content: '🤝'; }   
        
        .btn-link { display: inline-block; margin-top: 5px; font-size: 13px; color: #2c7be5; text-decoration: none; font-weight: bold; }
        .trade-actions { margin-left: 15px; display: flex; flex-direction: column; gap: 5px; justify-content: center; }
        .btn { padding: 8px 12px; font-size: 13px; border-radius: 4px; border: none; cursor: pointer; color: white; font-weight: bold; }
        .btn-accept { background-color: #81c147; }
        .btn-reject { background-color: #a0a0a0; }
        .no-data { text-align: center; padding: 40px; color: #888; font-size: 15px; background: #fcfcfc; border-radius: 5px; }

        /* 페이지네이션 스타일 */
        .pagination { display: flex; justify-content: center; margin-top: 20px; gap: 5px; }
        .page-link { padding: 5px 10px; border: 1px solid #ddd; color: #555; text-decoration: none; border-radius: 4px; font-size: 13px; }
        .page-link.active { background-color: #2c7be5; color: white; border-color: #2c7be5; }
        .page-link:hover:not(.active) { background-color: #f1f1f1; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="notification-container">
        
        <h2>
            들어온 거래 요청 
            <% if(!receivedList.isEmpty()) { %><span class="badge-count"><%= receivedList.size() %></span><% } %>
        </h2>
        <ul class="noti-list">
            <% if (receivedList.isEmpty()) { %>
                <li class="no-data">새로운 거래 요청이 없습니다.</li>
            <% } else { 
                for(TradeDTO t : receivedList) { %>
                <li class="noti-item type-TRADE">
                    <div class="noti-icon"></div>
                    <div class="noti-content">
                        <div class="noti-msg">
                            <span style="color:#2c7be5; font-weight:bold;"><%= t.getOtherNickname() %></span>님이 
                            <b>'<%= t.getProductName() %>'</b> 구매를 희망합니다.
                        </div>
                        <div class="noti-date"><%= sdf.format(t.getRequestedAt()) %></div>
                    </div>
                    <div class="trade-actions">
                        <button class="btn btn-accept" onclick="location.href='trade?cmd=decide&decision=ACCEPTED&trade_id=<%= t.getTradeId() %>'">수락</button>
                        <button class="btn btn-reject" onclick="location.href='trade?cmd=decide&decision=REJECTED&trade_id=<%= t.getTradeId() %>'">거절</button>
                    </div>
                </li>
            <% } } %>
        </ul>
        
        <% if (totalTradePages > 1) { %>
        <div class="pagination">
            <% for(int i=1; i<=totalTradePages; i++) { %>
                <a href="trade?cmd=notification&tradePage=<%= i %>&notiPage=<%= notiPage %>" 
                   class="page-link <%= (i == tradePage) ? "active" : "" %>"><%= i %></a>
            <% } %>
        </div>
        <% } %>

        <h2 style="margin-top: 50px;">알림 내역</h2>
        <ul class="noti-list">
            <% if (notiList.isEmpty()) { %>
                <li class="no-data">알림 내역이 없습니다.</li>
            <% } else { 
                for(NotificationDTO n : notiList) { %>
                <li class="noti-item type-<%= n.getType() %>">
                    <div class="noti-icon"></div>
                    <div class="noti-content">
                        <div class="noti-msg">
                            <%= n.getMessage() %>
                            <% if(n.getUrl() != null) { %>
                                <br><a href="<%= n.getUrl() %>" class="btn-link">자세히 보기 &gt;</a>
                            <% } %>
                        </div>
                        <div class="noti-date"><%= sdf.format(n.getCreatedAt()) %></div>
                    </div>
                </li>
            <% } } %>
        </ul>

        <% if (totalNotiPages > 1) { %>
        <div class="pagination">
            <% for(int i=1; i<=totalNotiPages; i++) { %>
                <a href="trade?cmd=notification&notiPage=<%= i %>&tradePage=<%= tradePage %>" 
                   class="page-link <%= (i == notiPage) ? "active" : "" %>"><%= i %></a>
            <% } %>
        </div>
        <% } %>
        
        <h2 style="margin-top: 50px;">내 요청 결과 (최근 10건)</h2>
        <ul class="noti-list">
            <% if (sentList.isEmpty()) { %>
                <li class="no-data">완료된 요청이 없습니다.</li>
            <% } else { 
                for(TradeDTO t : sentList) { 
                    if("REQUESTED".equals(t.getStatus())) continue; 
            %>
                <li class="noti-item type-TRADE">
                    <div class="noti-icon"></div>
                    <div class="noti-content">
                        <div class="noti-msg">
                            <% if ("ACCEPTED".equals(t.getStatus())) { %>
                                <b><%= t.getOtherNickname() %></b>님이 
                                <b>'<%= t.getProductName() %>'</b> 거래를 <span style="color:blue">수락</span>했습니다.<br>
                                <span style="font-size:13px; color:#555;">연락처: <%= t.getOtherPhone() %></span>
                            <% } else if ("REJECTED".equals(t.getStatus())) { %>
                                <b><%= t.getOtherNickname() %></b>님이 
                                <b>'<%= t.getProductName() %>'</b> 거래를 <span style="color:red">거절</span>했습니다.
                            <% } else if ("COMPLETED".equals(t.getStatus())) { %>
                                <b>'<%= t.getProductName() %>'</b> 거래가 <span style="color:green">완료</span>되었습니다.
                            <% } %>
                        </div>
                        <div class="noti-date"><%= (t.getAcceptedAt() != null) ? sdf.format(t.getAcceptedAt()) : "-" %></div>
                    </div>
                </li>
            <% } } %>
        </ul>

    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>