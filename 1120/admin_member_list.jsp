<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 관리자 권한 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String adminName = (String) session.getAttribute("userName");
    
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>
            alert("접근 권한이 없습니다.");
            location.href = "main_page.jsp"; 
        </script>
<%
        return;
    }

    request.setCharacterEncoding("UTF-8");

    // 2. 검색 파라미터
    String searchKeyword = request.getParameter("keyword");
    if (searchKeyword == null) searchKeyword = "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 전체 회원 목록</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

        /* [고정] 상단 헤더 CSS */
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }

        /* 관리자 레이아웃 CSS */
        .admin-wrapper { display: flex; max-width: 1400px; min-height: 70vh; margin: 20px auto; gap: 20px; }
        .admin-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px 0; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); align-self: flex-start; }
        .admin-sidebar h3 { font-size: 16px; color: #2c7be5; padding: 10px 20px; margin-top: 15px; margin-bottom: 5px; border-bottom: 1px solid #eee; }
        .admin-sidebar ul { list-style: none; padding: 0; margin: 0; }
        .admin-sidebar li a { display: block; padding: 12px 20px; text-decoration: none; color: #333; font-size: 14px; transition: background-color 0.1s; }
        .admin-sidebar li a:hover { background-color: #f5f5f5; }
        .admin-sidebar li.active a { background-color: #2c7be5; color: white; font-weight: 500; }
        
        .admin-content { flex-grow: 1; background-color: #ffffff; padding: 30px 40px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; }
        .admin-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .admin-header h2 { font-size: 24px; margin: 0; }

        /* 검색 영역 스타일 */
        .search-area { display: flex; gap: 10px; margin-bottom: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px; align-items: center; }
        .search-area input { flex-grow: 1; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; height: 40px; box-sizing: border-box; }
        .search-btn { background-color: #2c7be5; color: white; border: none; padding: 0 20px; height: 40px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .search-btn:hover { background-color: #1a68d1; }

        /* 회원 목록 테이블 스타일 */
        .member-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .member-table th, .member-table td { padding: 12px 10px; border-bottom: 1px solid #eee; text-align: center; }
        .member-table th { background-color: #f1f5f9; color: #555; font-weight: 600; border-top: 2px solid #2c7be5; }
        .member-table tr:hover { background-color: #f9f9f9; }
        
        .member-info { text-align: left; }
        .member-id { font-weight: bold; color: #333; display: block; }
        .member-sub { font-size: 12px; color: #888; }

        /* 배지 스타일 */
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .badge-admin { background-color: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; }
        .badge-user { background-color: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

        /* [고정] 하단 푸터 CSS */
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; margin-top: 40px; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }
        .admin-link { font-weight: bold; color: #2c7be5; margin-top: 10px; display: inline-block; }
        .admin-link:hover { text-decoration: underline; }
    </style>

    <script>
        function toggleDropdown() { document.getElementById("myDropdown").classList.toggle("show"); }
        window.onclick = function(event) {
            if (!event.target.matches('.dropdown-toggle')) {
                var dropdowns = document.getElementsByClassName("dropdown-content");
                for (var i = 0; i < dropdowns.length; i++) {
                    var openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) { openDropdown.classList.remove('show'); }
                }
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="logo"><a href="main_page.jsp"><img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;"></a></div>
        <div class="header-links">
            <div class="welcome-message">관리자 <%= adminName %>님, 환영합니다.</div>
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                <div id="myDropdown" class="dropdown-content">
                    <a href="mypage.jsp">마이페이지</a>
                    <a href="logout.jsp">로그아웃</a>
                </div>
            </div>
            <input type="button" value="" onclick="location.href='notifications.jsp'" style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center; background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
        </div>
    </header>

    <div class="admin-wrapper">
        <nav class="admin-sidebar">
            <h3>회원 관리</h3>
            <ul>
                <li class="active"><a href="admin_member_list.jsp">회원 목록</a></li> 
                <li><a href="#">회원 정지/탈퇴</a></li> 
            </ul>
            
            <h3>상품 관리</h3>
            <ul>
                <li><a href="admin_product_list.jsp">전체 상품 목록</a></li> 
                <li><a href="#">상품 등록 (미사용)</a></li> 
            </ul>

            <h3>고객 지원</h3>
            <ul>
                <li><a href="inquiry_list.jsp">1:1 문의</a></li> 
                <li><a href="faq_list.jsp">FAQ</a></li> 
                <li><a href="notice_list.jsp">공지사항</a></li> 
            </ul>

            <h3>통계</h3>
            <ul>
                <li><a href="#">전체 통계</a></li> 
            </ul>
        </nav>
        
        <main class="admin-content">
            <div class="admin-header">
                <h2>전체 회원 목록</h2>
            </div>
            
            <form action="admin_member_list.jsp" method="get" class="search-area">
                <input type="text" name="keyword" placeholder="아이디 또는 닉네임 검색" value="<%= searchKeyword %>">
                <button type="submit" class="search-btn">검색</button>
            </form>

            <table class="member-table">
                <colgroup>
                    <col style="width: 8%;">  <col style="width: 30%;"> <col style="width: 17%;"> <col style="width: 20%;"> <col style="width: 15%;"> <col style="width: 10%;"> </colgroup>
                <thead>
                    <tr>
                        <th>No.</th>
                        <th>회원정보 (아이디/이메일)</th>
                        <th>닉네임</th>
                        <th>연락처</th>
                        <th>가입일</th>
                        <th>구분</th>
                        </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                            
                            // ✨ DB 컬럼 추가 반영: created_at으로 정렬
                            String sql = "SELECT * FROM member WHERE (id LIKE ? OR nickname LIKE ?) ORDER BY created_at DESC";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, "%" + searchKeyword + "%");
                            pstmt.setString(2, "%" + searchKeyword + "%");
                            
                            rs = pstmt.executeQuery();
                            
                            int rowNum = 1;
                            boolean hasMembers = false;

                            while (rs.next()) {
                                hasMembers = true;
                                String mId = rs.getString("id");
                                String mNick = rs.getString("nickname");
                                String mEmail = rs.getString("email");
                                String mPhone = rs.getString("phone");
                                
                                // 가입일 (created_at)
                                String mRegDate = "-";
                                try {
                                    Timestamp ts = rs.getTimestamp("created_at");
                                    if (ts != null) mRegDate = sdf.format(ts);
                                } catch (SQLException e) { }
                                
                                boolean isMemberAdmin = false;
                                try {
                                    String adminFlag = rs.getString("isAdmin"); 
                                    isMemberAdmin = (adminFlag != null && adminFlag.equals("true"));
                                } catch (SQLException e) { }
                    %>
                        <tr>
                            <td><%= rowNum++ %></td>
                            <td class="member-info">
                                <span class="member-id"><%= mId %></span>
                                <span class="member-sub"><%= mEmail != null ? mEmail : "-" %></span>
                            </td>
                            <td><%= mNick != null ? mNick : "-" %></td>
                            <td><%= mPhone != null ? mPhone : "-" %></td>
                            <td><%= mRegDate %></td>
                            <td>
                                <% if (isMemberAdmin) { %>
                                    <span class="badge badge-admin">관리자</span>
                                <% } else { %>
                                    <span class="badge badge-user">회원</span>
                                <% } %>
                            </td>
                            </tr>
                    <%
                            }
                            
                            if (!hasMembers) {
                    %>
                        <tr>
                            <td colspan="6" style="padding: 50px; color: #888;">검색된 회원이 없습니다.</td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<tr><td colspan='6' style='color:red;'>오류 발생: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
                            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                        }
                    %>
                </tbody>
            </table>
        </main>
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
        <div style="display: flex; gap: 40px;">
            <div class="footer-section">
                <h4>ABOUT</h4>
                <a href="company_intro.jsp"> 회사소개 </a><br>
                <a href="notice_list.jsp"> 공지사항 </a><br>
            </div>
            <div class="footer-section">
                <h4>SUPPORT</h4>
                <a href="inquiry_list.jsp"> 1:1 문의 </a><br>
                <a href="faq_list.jsp"> FAQ </a>
                <br><a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
            </div>
        </div>
    </footer>
</body>
</html>