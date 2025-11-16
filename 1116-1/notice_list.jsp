
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 세션에서 사용자 및 관리자 정보 확인
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    // isAdmin 변수를 isManager로 boolean 타입으로 사용
    // login.jsp 파일에 따라, 세션 값이 "true"일 경우 관리자로 판단
    boolean isManager = "true".equals(session.getAttribute("isAdmin"));

    // 공지사항 목록 데이터를 담을 리스트
    List<Map<String, Object>> noticeList = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    // ✨ 1-1. 정렬 (Sorting) 기준 처리
    // 현재 URL에서 sort 파라미터를 가져와 정렬 기준을 결정합니다.
    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) {
        sort = "latest"; // 기본값: 최신순
    }
    
    String orderByClause = "";
    switch (sort) {
        case "latest":
            orderByClause = "reg_date DESC"; 
            break;
        case "oldest":
            orderByClause = "reg_date ASC";  
            break;
        case "id_desc":
            orderByClause = "notice_id DESC"; // (DB ID 기준)
            break;
        default:
            orderByClause = "reg_date DESC";
            break;
    }

    try {
        // DB 연결
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // ✨ 1-2. SQL 수정: 작성자(member 테이블) JOIN을 제거하고 Notice 테이블에서만 조회
        // DB 구조 변경 없이 단순 목록 조회가 가능합니다.
        String sql = "SELECT notice_id, title, reg_date FROM Notice ORDER BY " + orderByClause; 
                     
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> notice = new HashMap<>();
            notice.put("notice_id", rs.getInt("notice_id"));
            notice.put("title", rs.getString("title"));
            notice.put("reg_date", sdf.format(rs.getTimestamp("reg_date")));
            // 작성자 정보는 DB에서 가져오지 않으므로 Map에 넣지 않습니다.
            noticeList.add(notice);
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 조회 중 오류가 발생했습니다. (DB 연결 정보 또는 쿼리 확인)');</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 목록</title>
    
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

        /* 목록 스타일 */
        .notice-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 20px;
            background-color: #ffffff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        .notice-container h2 {
            text-align: center;
            font-size: 28px;
            color: #2c7be5;
            margin-bottom: 30px;
        }
        /* ✨ 정렬/개수 표시를 위한 바 스타일 */
        .notice-header-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding: 0 5px;
        }

        .sort-options select {
            padding: 8px 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
        }
        
        .notice-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 15px;
        }
        .notice-table th, .notice-table td {
            padding: 15px 10px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }
        .notice-table th {
            background-color: #f5f5f5;
            color: #555;
            font-weight: 700;
            border-top: 2px solid #2c7be5;
        }
        .notice-table tbody tr:hover {
            background-color: #fcfcfc;
        }
        .notice-table td.title {
            text-align: left;
            padding-left: 20px;
        }
        .notice-table td.title a {
            color: #333;
            text-decoration: none;
            font-weight: 500;
        }
        .notice-table td.title a:hover {
            text-decoration: underline;
            color: #2c7be5;
        }
        .notice-table td.management a {
            /* 수정/삭제 버튼 스타일 */
            color: #2c7be5;
            text-decoration: none;
            margin: 0 5px;
            font-size: 13px;
            font-weight: 500;
        }
        .notice-table td.management a:last-child {
             color: #dc3545; /* 삭제는 빨간색 */
        }
        .notice-table td.management a:hover {
            font-weight: 700;
        }

        .write-btn-area {
            text-align: right;
            margin-top: 20px;
        }
        .write-btn {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .write-btn:hover {
            background-color: #1e7e34;
        }
        .no-data {
            text-align: center;
            padding: 50px;
            color: #777;
            font-size: 16px;
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
            
            const urlParams = new URLSearchParams(window.location.search);
            const msg = urlParams.get('msg');
            
            if (msg === 'deleted') {
                showToast('공지사항이 성공적으로 삭제되었습니다.', 'success', 2000);
                history.replaceState(null, '', location.pathname); 
            } else if (msg === 'delete_error') {
                showToast('공지사항 삭제 중 오류가 발생했습니다.', 'error', 3000);
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
        
        // 🚨 관리자용: 목록에서 삭제 확인 함수
        function confirmDelete(noticeId) {
            if (confirm("정말로 이 공지사항을 삭제하시겠습니까?")) {
                location.href = 'notice_delete_action.jsp?notice_id=' + noticeId;
            }
            return false;
        }
        
        // ✨ 정렬 기준 변경 시 페이지 리로드 함수
        function changeSort() {
            const selectBox = document.getElementById('sortSelect');
            const selectedSort = selectBox.value;
            location.href = 'notice_list.jsp?sort=' + selectedSort;
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
        <h2>공지사항</h2>
        
        <div class="notice-header-bar">
            <div class="total-count">
                총 <%= noticeList.size() %>개
            </div>
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
                    <th style="width: <%= isManager ? "60%" : "75%" %>;">제목</th> <th style="width: 15%;">등록일</th>
                    <% if (isManager) { %>
                        <th style="width: 15%;">관리</th> <%-- 관리자일 경우 수정/삭제 컬럼 추가 --%>
                    <% } %>
                </tr>
            </thead>
            <tbody>
                <% if (noticeList.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= isManager ? "4" : "3" %>" class="no-data">등록된 공지사항이 없습니다.</td>
                    </tr>
                <% } else { %>
                    <% 
                    // ✨ 목록 번호를 1부터 시작하도록 카운터 변수 선언 및 초기화
                    int rowNum = 1; 
                    for (Map<String, Object> notice : noticeList) { 
                    %>
                        <tr>
                            <td><%= rowNum++ %></td>
                            <td class="title">
                                <a href="notice_detail.jsp?notice_id=<%= notice.get("notice_id") %>">
                                    <%= notice.get("title") %>
                                </a>
                            </td>
                            <td><%= notice.get("reg_date") %></td>
                            <% if (isManager) { %>
                                <td class="management">
                                    <a href="notice_update_form.jsp?notice_id=<%= notice.get("notice_id") %>">수정</a>
                                    <a href="#" onclick="return confirmDelete(<%= notice.get("notice_id") %>)">삭제</a>
                                </td>
                            <% } %>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
        
        <% if (isManager) { %>
            <div class="write-btn-area">
                <a href="notice_add_form.jsp" class="write-btn">공지사항 작성</a>
            </div>
        <% } %>
        
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
        		<a href="faq_list.jsp"> <%= faq %> </a>
                <br>
                <% if (isManager) { %>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                <% } %>
    		</div>
		</div>
    </footer>
    
</body>
</html>
