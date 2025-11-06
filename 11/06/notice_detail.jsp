<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 세션에서 사용자 및 관리자 정보 확인
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String isAdmin = (String) session.getAttribute("isAdmin");
    boolean isManager = (isAdmin != null && isAdmin.equals("true"));

    // 2. notice_id 파라미터 받기
    String noticeIdStr = request.getParameter("notice_id");
    if (noticeIdStr == null || noticeIdStr.trim().isEmpty()) {
        out.println("<script>location.href='notice_list.jsp';</script>");
        return;
    }
    int notice_id = 0;
    try {
        notice_id = Integer.parseInt(noticeIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>location.href='notice_list.jsp';</script>");
        return;
    }

    // 공지사항 상세 정보를 담을 변수
    String title = "";
    String content = "";
    String regDate = "";
    boolean found = false;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    try {
        // DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 공지사항 상세 내용 조회
        String selectSql = "SELECT title, content, reg_date FROM Notice WHERE notice_id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setInt(1, notice_id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content"); 
            regDate = sdf.format(rs.getTimestamp("reg_date"));
            found = true;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // 자원 정리
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    
    // 공지사항을 찾지 못했을 경우
    if (!found) {
        out.println("<script>location.href='notice_list.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

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

        /* 공통 스타일 */
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
        
        /* 상세 스타일 */
        .notice-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background-color: #ffffff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        .notice-title {
            font-size: 28px;
            font-weight: 700;
            color: #333;
            padding-bottom: 10px;
            border-bottom: 3px solid #2c7be5;
        }
        .notice-info {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #777;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
            margin-bottom: 30px;
        }
        .notice-content {
            font-size: 16px;
            line-height: 1.8;
            min-height: 200px; 
            white-space: pre-wrap; 
            padding: 20px 0;
        }
        
        .detail-actions {
            text-align: right;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .detail-actions a {
            padding: 10px 15px;
            font-size: 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-left: 10px;
            font-weight: 500;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        .detail-actions .list-btn {
            background-color: #6c757d; 
            color: white;
        }
        .detail-actions .list-btn:hover {
            background-color: #5a6268;
        }
        .detail-actions .admin-edit-btn {
            background-color: #2c7be5; 
            color: white;
        }
        .detail-actions .admin-edit-btn:hover {
            background-color: #256bc7;
        }
        .detail-actions .admin-delete-btn {
            background-color: #dc3545; 
            color: white;
        }
        .detail-actions .admin-delete-btn:hover {
            background-color: #c82333;
        }

        /* 푸터 스타일 */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 40px;
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
    </style>

    <script>
        // 토스트 메시지 함수
        document.addEventListener('DOMContentLoaded', (event) => {
            let container = document.getElementById('toast-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toast-container';
                document.body.appendChild(container);
            }
            
            // URL 파라미터를 확인하여 토스트 메시지 출력 (수정 완료 메시지)
            const urlParams = new URLSearchParams(window.location.search);
            const msg = urlParams.get('msg');
            
            if (msg === 'updated') {
                showToast('공지사항이 성공적으로 수정되었습니다.', 'success', 2000);
                
                // URL에서 msg 파라미터 제거
                const newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + '?notice_id=<%= notice_id %>';
                window.history.replaceState({path: newUrl}, '', newUrl);
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
        
        // 🚨 관리자용: 삭제 확인 함수
        function confirmDelete(noticeId) {
            if (confirm("정말로 이 공지사항을 삭제하시겠습니까?")) {
                location.href = 'notice_delete_action.jsp?notice_id=' + noticeId;
            }
            return false; 
        }
        
        // 드롭다운 토글 함수
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
    <div id="toast-container"></div>
    
    <header>
        <div class="logo">
            <a href="main_page.jsp">
                <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;" alt="중고모아 로고">
            </a>
        </div>
        <div class="header-links">
            <div class="welcome-message">
                <% 
                    if (userName != null) {
                        out.print(userName + "님, 환영합니다.");
                    } else {
                        out.print("<a href='loginpage.jsp' style='margin:0; color:#2c7be5; font-weight:700;'>로그인</a>");
                    }
                %>
            </div>
            
            <% if (userId != null) { %>
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                    </div>
                </div>
                <input type="button" value="" onclick="location.href='notifications.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
            <% } %>
        </div>
    </header>

    <div class="notice-container">
        <div class="notice-title"><%= title %></div>
        
        <div class="notice-info">
            <span>작성자: 관리자</span>
            <span>등록일: <%= regDate %></span>
        </div>
        
        <div class="notice-content">
            <%= content %>
        </div>

        <div class="detail-actions">
            <a href="notice_list.jsp" class="list-btn">목록으로</a>
            
            <% if (isManager) { %>
                <a href="notice_update_form.jsp?notice_id=<%= notice_id %>" class="admin-edit-btn">수정</a>
                <a href="#" onclick="return confirmDelete(<%= notice_id %>)" class="admin-delete-btn">삭제</a>
            <% } %>
        </div>
    </div>

    <footer>
        <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;" alt="로고2" />
            <p>(주) 중고모아 | 대표 김령균</p>
            <p>TEL : 010-0000-0000</p>
            <p>Mail : junggomoa@gmail.com</p>
            <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
            <p>이용약관 / 개인정보처리방침</p>
        </div>
        <%
    	String companyIntro = "회사소개";
		String noticeLink = "공지사항";
    	String question = "1:1 문의";
    	String faq = "FAQ";
		%>
		<div style="display: flex; gap: 40px;">
    		<div class="footer-section">
        		<h4>ABOUT</h4>
        		<a href="company_intro.jsp"> <%= companyIntro %> </a><br>
        		<a href="notice_list.jsp"> <%= noticeLink %> </a><br>
    		</div>
    		<div class="footer-section">
        		<h4>SUPPORT</h4>
        		<a href="#"> <%= question %> </a><br>
        		<a href="#"> <%= faq %> </a>
                <br>
                <% if (isManager) { %>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                <% } %>
    		</div>
		</div>
    </footer>
</body>
</html>