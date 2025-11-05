<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>

<%
    // 1. (세션 정보 로드) 헤더/푸터 사용을 위해 세션 변수 로드
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String isAdmin = (String) session.getAttribute("isAdmin"); 

    // 2. 공지사항 데이터베이스 조회 로직 준비
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 가상의 Notice 데이터 클래스 (실제 DB 연결 시 대체됨)
    class Notice {
        int noticeId;
        String title;
        String regDate;
        int views;
        String writer;
        
        public Notice(int id, String t, String d, int v, String w) {
            this.noticeId = id;
            this.title = t;
            this.regDate = d;
            this.views = v;
            this.writer = w;
        }
    }
    
    ArrayList<Notice> noticeList = new ArrayList<>();
    int totalCount = 0;
    int pageSize = 10;
    int currentPage = 1;
    
    // 페이지 번호 파라미터 처리
    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    int startRow = (currentPage - 1) * pageSize;
    int totalPage = 1;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 1. 전체 공지사항 개수 조회
        String countSql = "SELECT COUNT(*) FROM Notice"; // Notice 테이블이 있다고 가정
        pstmt = conn.prepareStatement(countSql);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalCount = rs.getInt(1);
        }
        
        if (totalCount > 0) {
            totalPage = (int) Math.ceil((double) totalCount / pageSize);
            if (currentPage > totalPage) currentPage = totalPage; // 현재 페이지가 총 페이지를 넘지 않도록
            startRow = (currentPage - 1) * pageSize; // startRow 재계산
        }

        rs.close();
        pstmt.close();

        // 2. 현재 페이지 공지사항 목록 조회 (예시 쿼리)
        String listSql = "SELECT notice_id, title, reg_date, views, '관리자' as writer FROM Notice ORDER BY notice_id DESC LIMIT ?, ?";
        pstmt = conn.prepareStatement(listSql);
        pstmt.setInt(1, startRow);
        pstmt.setInt(2, pageSize);
        rs = pstmt.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
        
        while(rs.next()) {
            int id = rs.getInt("notice_id");
            String title = rs.getString("title");
            Date date = rs.getTimestamp("reg_date");
            int views = rs.getInt("views");
            String dateStr = sdf.format(date);
            
            noticeList.add(new Notice(id, title, dateStr, views, "관리자"));
        }
        
    } catch (Exception e) {
        // e.printStackTrace(); 
        // 실제 DB 연동 실패 시를 대비하여 가상의 데이터로 대체 (디자인 확인용)
        noticeList.clear();
        noticeList.add(new Notice(5, "[공지] 시스템 점검 안내 (11/10)", "2025.11.05", 150, "관리자"));
        noticeList.add(new Notice(4, "[이벤트] 중고모아 가을맞이 특별 쿠폰 지급", "2025.10.20", 300, "관리자"));
        noticeList.add(new Notice(3, "개인정보 처리방침 변경 안내", "2025.10.01", 120, "관리자"));
        noticeList.add(new Notice(2, "불량 사용자 신고 및 처리 기준 강화", "2025.09.15", 80, "관리자"));
        noticeList.add(new Notice(1, "중고모아 서비스 오픈을 환영합니다!", "2025.09.01", 500, "관리자"));
        
        totalCount = 5;
        totalPage = 1;

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
    <title>중고모아 - 공지사항</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* 1. 헤더 스타일 (학습된 구조 유지) */
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


        /* 2. 메인 콘텐츠 영역 (공지사항 목록) */
        .page-content {
            width: 80%;
            max-width: 1200px;
            margin: 40px auto;
            padding: 30px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }

        .page-content h2 {
            font-size: 28px;
            font-weight: 700;
            color: #2c7be5; 
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 30px;
        }
        
        /* 공지사항 테이블 스타일 */
        .notice-table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
            font-size: 15px;
        }

        .notice-table th {
            background-color: #f0f0f0;
            color: #333;
            font-weight: 700;
            padding: 15px 10px;
            border-top: 2px solid #2c7be5;
            border-bottom: 1px solid #ddd;
        }

        .notice-table td {
            padding: 15px 10px;
            border-bottom: 1px solid #eee;
            color: #555;
        }
        
        .notice-table tr:hover {
            background-color: #f7f7f7;
            cursor: pointer;
        }

        .notice-table .title {
            text-align: left;
            padding-left: 20px;
            font-weight: 500;
            color: #333;
            white-space: nowrap; /* 줄바꿈 방지 */
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 500px; 
        }
        
        .notice-table .title a {
            text-decoration: none;
            color: inherit;
        }
        
        /* 페이지네이션 스타일 */
        .pagination {
            text-align: center;
            margin-top: 30px;
        }

        .pagination a, .pagination span {
            display: inline-block;
            padding: 8px 14px;
            margin: 0 3px;
            border: 1px solid #ccc;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: background-color 0.2s;
        }

        .pagination a:hover {
            background-color: #eee;
        }

        .pagination .current {
            background-color: #2c7be5;
            color: white;
            border-color: #2c7be5;
            cursor: default;
        }

        /* 3. 푸터 스타일 (학습된 구조 유지) */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 40px; /* 메인 콘텐츠와의 간격 확보 */
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
                <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;" alt="중고모아 로고">
            </a>
        </div>
        <div class="header-links">
        
            <%
            if (userId == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
                
                <input type="button" value="" onclick="location.href='loginpage.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
            <%
            } else {
            %>
                <div class="welcome-message">
                    <%= userName %>님, 환영합니다.
                </div>

                <input type="button" value="" onclick="location.href='notifications.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
                
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                    
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                        <a href="product_add_form.jsp">상품 등록</a>
                    </div>
                </div>
                
            <%
            }
            %>
        </div>
    </header>

    <div class="page-content">
        <h2>공지사항</h2>

        <table class="notice-table">
            <thead>
                <tr>
                    <th style="width: 8%;">번호</th>
                    <th style="width: 50%;">제목</th>
                    <th style="width: 12%;">작성자</th>
                    <th style="width: 15%;">등록일</th>
                    <th style="width: 15%;">조회수</th>
                </tr>
            </thead>
            <tbody>
                <% if (noticeList.isEmpty()) { %>
                <tr>
                    <td colspan="5">등록된 공지사항이 없습니다.</td>
                </tr>
                <% } else { %>
                    <% 
                    int listNum = totalCount - startRow;
                    for (Notice notice : noticeList) { 
                    %>
                    <tr>
                        <td><%= listNum-- %></td>
                        <td class="title">
                            <a href="notice_detail.jsp?notice_id=<%= notice.noticeId %>">
                                <%= notice.title %>
                            </a>
                        </td>
                        <td><%= notice.writer %></td>
                        <td><%= notice.regDate %></td>
                        <td><%= notice.views %></td>
                    </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>
        
        <div class="pagination">
            <% 
                // 페이지 그룹 설정 (1, 2, 3, 4, 5...)
                int blockSize = 5;
                int startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
                int endPage = startPage + blockSize - 1;
                
                if (endPage > totalPage) {
                    endPage = totalPage;
                }

                // [처음] & [이전]
                if (startPage > 1) {
                    out.println("<a href='notice_list.jsp?page=1'>&lt;&lt;</a>");
                    out.println("<a href='notice_list.jsp?page=" + (startPage - 1) + "'>&lt;</a>");
                }
                
                // 페이지 번호
                for (int i = startPage; i <= endPage; i++) {
                    if (i == currentPage) {
                        out.println("<span class='current'>" + i + "</span>");
                    } else {
                        out.println("<a href='notice_list.jsp?page=" + i + "'>" + i + "</a>");
                    }
                }

                // [다음] & [끝]
                if (endPage < totalPage) {
                    out.println("<a href='notice_list.jsp?page=" + (endPage + 1) + "'>&gt;</a>");
                    out.println("<a href='notice_list.jsp?page=" + totalPage + "'>&gt;&gt;</a>");
                }
            %>
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
        
        <div style="display: flex; gap: 40px;">
            <div class="footer-section">
                <h4>ABOUT</h4>
                <a href="company_intro.jsp"> 회사소개 </a><br>
                <a href="notice_list.jsp"> 공지사항 </a><br>
            </div>
            <div class="footer-section">
                <h4>SUPPORT</h4>
                <a href="#"> 1:1 문의 </a><br>
                <a href="#"> FAQ </a>
                
                <%
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