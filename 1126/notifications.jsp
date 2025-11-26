<%@ page contentType="text/html; charset=UTF-8" language="java"
    import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
%>
        <script>
            alert("로그인이 필요합니다.");
            location.href = "loginpage.jsp";
        </script>
<%
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt1 = null;
    ResultSet rs1 = null;
    PreparedStatement pstmt2 = null;
    ResultSet rs2 = null;
    
    SimpleDateFormat sdf = new SimpleDateFormat("MM월 dd일 HH:mm");
    boolean hasRequests = false; 
    boolean hasResults = false; 

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // --- 1. (판매자) 내가 받은 거래 요청 ---
        String sql1 = "SELECT tr.trade_id, m.nickname AS buyer_nickname, p.product_name, tr.requested_at " +
                      "FROM TradeRequest tr " +
                      "JOIN member m ON tr.buyer_id = m.id " +
                      "JOIN Product p ON tr.product_id = p.product_id " +
                      "WHERE tr.seller_id = ? AND tr.status = 'REQUESTED' " +
                      "ORDER BY tr.requested_at DESC";
        
        pstmt1 = conn.prepareStatement(sql1);
        pstmt1.setString(1, userId);
        rs1 = pstmt1.executeQuery(); 
        
        // --- 2. (구매자) 내가 보낸 요청의 결과 (수락/거절) ---
        String sql2 = "SELECT tr.trade_id, p.product_name, tr.status, tr.accepted_at, " +
                      "       m.nickname AS seller_nickname, m.phone " +
                      "FROM TradeRequest tr " +
                      "JOIN Product p ON tr.product_id = p.product_id " +
                      "JOIN member m ON tr.seller_id = m.id " +
                      "WHERE tr.buyer_id = ? AND (tr.status = 'ACCEPTED' OR tr.status = 'REJECTED') " +
                      "ORDER BY tr.accepted_at DESC";
                      
        pstmt2 = conn.prepareStatement(sql2);
        pstmt2.setString(1, userId);
        rs2 = pstmt2.executeQuery();

%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>중고모아 - 알림</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 40px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .logo img {
            height: 60px;
            width: 200px;
            object-fit: contain; 
        }
        .header-links {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .welcome-message {
            font-size: 14px;
            color: #333;
            font-weight: 500;
        }
        .header-links a {
            margin-left: 20px;
            text-decoration: none;
            color: #555;
            font-size: 14px;
        }
        .dropdown {
            position: relative;
            display: inline-block;
        }
        .dropdown-toggle {
            height: 40px;
            width: 40px;
            cursor: pointer;
            border-radius: 50%;
            object-fit: cover;
        }
        .dropdown-content {
            display: none;
            position: absolute;
            right: 0;
            background-color: #ffffff;
            min-width: 120px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            z-index: 1001;
            border-radius: 5px;
        }
        .dropdown-content a {
            color: #333;
            padding: 12px 16px;
            text-decoration: none;
            display: block;
            margin: 0;
            font-size: 14px;
        }
        .dropdown-content a:hover {
            background-color: #f1f1f1;
        }
        .show {
            display: block;
        }
        .notification-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px 40px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            min-height: 500px;
        }
        .notification-container h2 {
            font-size: 24px;
            margin-bottom: 25px;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
        }
        .notification-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .notification-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 10px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.2s;
        }
        .notification-item:hover {
            background-color: #f9f9f9;
        }
        .notification-icon {
            font-size: 24px;
            margin-right: 20px;
            flex-shrink: 0;
        }
        .notification-content {
            flex-grow: 1;
        }
        .notification-content .message {
            font-size: 16px;
            color: #333;
            font-weight: 500;
        }
        .notification-content .message .highlight {
            color: #81c147;
            font-weight: 700;
        }
        .notification-content .message .highlight-red {
            color: #d9534f;
            font-weight: 700;
        }
        .notification-content .message .contact-info {
            color: #2c7be5;
            font-weight: 700;
            font-size: 15px;
            margin-top: 5px;
        }
        .notification-content .timestamp {
            font-size: 14px;
            color: #888;
            margin-top: 5px;
        }
        .notification-item.type-chat .notification-icon::before {
            content: '💬';
        }
        .notification-item.type-result .notification-icon::before {
            content: '📈';
        }
        .no-notifications {
            text-align: center;
            padding: 50px 0;
            color: #888;
            font-size: 16px;
        }
        .notification-actions {
            display: flex;
            gap: 10px;
            flex-shrink: 0;
            margin-left: 20px;
        }
        .notification-actions .btn {
            padding: 8px 15px;
            font-size: 14px;
            font-weight: 500;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .notification-actions .btn-accept {
            background-color: #81c147;
            color: white;
        }
        .notification-actions .btn-accept:hover {
            background-color: #6da33a;
        }
        .notification-actions .btn-reject {
            background-color: #a0a0a0;
            color: white;
        }
        .notification-actions .btn-reject:hover {
            background-color: #888888;
        }
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
        }
        .footer-section h4 {
            margin-bottom: 10px;
            font-weight: bold;
        }
        .footer-section p,
        .footer-section a {
            margin: 4px 0;
            text-decoration: none;
            color: #555;
        }
        .admin-link {
            font-weight: bold;
            color: #2c7be5; 
            margin-top: 10px;
            display: inline-block;
        }
        .admin-link:hover {
            text-decoration: underline;
        }
    </style>
    
    <script>
        function toggleDropdown() {
            document.getElementById("myDropdown").classList.toggle("show");
        }

        window.onclick = function(event) {
            if (!event.target.matches('.dropdown-toggle')) {
                var dropdowns = document.getElementsByClassName("dropdown-content");
                for (var i = 0; i < dropdowns.length; i++) {
                    var openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) {
                        openDropdown.classList.remove('show');
                    }
                }
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="logo">
            <a href="main_page.jsp">
    		    <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;">
            </a>
		</div>
     
        <div class="header-links">
            <%
            if (userId == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
                <input type="button" value="" onclick="location.href='loginpage.jsp'"
                   style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                   background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
            <%
            } else {
            %>
                <div class="welcome-message">
                    <%= (String)session.getAttribute("userName") %>님, 환영합니다.
                </div>
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                    </div>
                </div>
                <input type="button" value="" onclick="location.href='notifications.jsp'"
                   style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                   background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
            <%
            }
            %>
        </div>
    </header>
    
    <div class="notification-container">
        <h2>새로운 거래 요청 (판매자)</h2>
        
        <ul class="notification-list">
            <%
                if (rs1 != null) {
                    hasRequests = rs1.next(); 
                    if (!hasRequests) {
            %>
                        <li class="no-notifications">
                            새로운 거래 요청이 없습니다.
                        </li>
            <%
                    } else {
                        do {
            %>
                            <li class="notification-item type-chat">
                                <div class="notification-icon"></div>
                                <div class="notification-content">
                                    <div class="message">
                                        <span class="highlight"><%= rs1.getString("buyer_nickname") %></span>님이
                                        '<span class="highlight"><%= rs1.getString("product_name") %></span>' 상품에 대해 거래 요청을 보냈습니다.
                                    </div>
                                    <div class="timestamp"><%= sdf.format(rs1.getTimestamp("requested_at")) %></div>
                                </div>
                                
                                <div class="notification-actions">
                                    <form action="trade_accept_action.jsp" method="POST" style="margin:0;">
                                        <input type="hidden" name="trade_id" value="<%= rs1.getString("trade_id") %>">
                                        <input type="hidden" name="action" value="accept">
                                        <button type="submit" class="btn btn-accept">수락</button>
                                    </form>
                                    <form action="trade_accept_action.jsp" method="POST" style="margin:0;">
                                        <input type="hidden" name="trade_id" value="<%= rs1.getString("trade_id") %>">
                                        <input type="hidden" name="action" value="reject">
                                        <button type="submit" class="btn btn-reject">거절</button>
                                    </form>
                                </div>
                            </li>
            <%
                        } while (rs1.next());
                    }
                }
            %>
        </ul>
        
        <h2 style="margin-top: 40px;">내 요청 결과 (구매자)</h2>
        
        <ul class="notification-list">
            <%
                if (rs2 != null) {
                    hasResults = rs2.next(); 
                    if (!hasResults) {
            %>
                        <li class="no-notifications">
                            처리된 요청 결과가 없습니다.
                        </li>
            <%
                    } else {
                        do {
                            String status = rs2.getString("status");
            %>
                            <li class="notification-item type-result">
                                <div class="notification-icon"></div>
                                <div class="notification-content">
                                    <% if ("ACCEPTED".equals(status)) { %>
                                        <div class="message">
                                            <span class="highlight"><%= rs2.getString("seller_nickname") %></span>님이
                                            '<span class="highlight"><%= rs2.getString("product_name") %></span>' 상품의 거래를 수락했습니다.
                                            <div class="contact-info">
                                                판매자 연락처: <%= rs2.getString("phone") %>
                                            </div>
                                        </div>
                                        <div class="timestamp"><%= sdf.format(rs2.getTimestamp("accepted_at")) %></div>
                                    <% } else { %>
                                        <div class="message">
                                            <span class="highlight-red"><%= rs2.getString("seller_nickname") %></span>님이
                                            '<span class="highlight-red"><%= rs2.getString("product_name") %></span>' 상품의 거래를 거절했습니다.
                                            <div class="timestamp" style="color: #d9534f; margin-top: 5px;">
                                                거래가 성립되지 않았습니다.
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            </li>
            <%
                        } while (rs2.next());
                    }
                }
            %>
        </ul>
        
    </div>

    <footer>
        <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;" />
            <p>(주) 중고모아 | 대표 김령균</p>
            <p>TEL : 010-0000-0000</p>
            <p>Mail : junggomoa@gmail.com</p>
            <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
            <p>이용약관 / 개인정보처리방침</p>
        </div>
        <%
    	String companyIntro = "회사소개";
		String notice = "공지사항";
    	String question = "1:1 문의";
    	String faq = "FAQ";
		%>
		<div style="display: flex; gap: 40px;">
    		<div class="footer-section">
        		<h4>ABOUT</h4>
        		<a href="company_intro.jsp"> <%= companyIntro %> </a><br>
        		<a href="notice_list.jsp"> <%= notice %> </a><br>
    		</div>
    		<div class="footer-section">
        		<h4>SUPPORT</h4>
        		<a href="#"> <%= question %> </a><br>
        		<a href="#"> <%= faq %> </a>
                <%
                    String isAdmin = (String) session.getAttribute("isAdmin");
                    if (isAdmin != null && isAdmin.equals("true")) {
                %>
                    <br>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                <%
                    }
                %>
    		</div>
		</div>
    </footer>
    
</body>
</html>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs1 != null) try { rs1.close(); } catch (SQLException ignore) {}
        if (pstmt1 != null) try { pstmt1.close(); } catch (SQLException ignore) {}
        if (rs2 != null) try { rs2.close(); } catch (SQLException ignore) {}
        if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>