<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 관리자 권한 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String adminName = (String) session.getAttribute("userName");
    
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>alert("접근 권한이 없습니다."); location.href = "main_page.jsp";</script>
<%
        return;
    }

    // =======================================================
    // 📊 DB 통계 데이터 처리 영역
    // =======================================================
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int[] memberCounts = new int[4]; 
    int[] productCounts = new int[4];
    List<Map<String, Integer>> categoryStats = new ArrayList<>();
    for(int i=0; i<4; i++) categoryStats.add(new HashMap<>());
    List<String> allCategoryNames = new ArrayList<>();

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        // 카테고리 목록 확보
        String catSql = "SELECT category_name FROM category ORDER BY sort_order ASC"; 
        try {
            pstmt = conn.prepareStatement(catSql);
            rs = pstmt.executeQuery();
            while(rs.next()){ allCategoryNames.add(rs.getString("category_name")); }
        } catch(Exception e) {
            if(pstmt!=null) pstmt.close();
            pstmt = conn.prepareStatement("SELECT DISTINCT category_name FROM category");
            rs = pstmt.executeQuery();
            while(rs.next()){ allCategoryNames.add(rs.getString("category_name")); }
        } finally {
            if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close();
        }

        String[] dateConditions = {
            "", 
            "AND created_at >= CURDATE()", 
            "AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)", 
            "AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)" 
        };

        // 회원 수 및 상품 수 조회
        for (int i = 0; i < 4; i++) {
            try {
                String sql = "SELECT COUNT(*) FROM member WHERE 1=1 " + dateConditions[i];
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();
                if (rs.next()) memberCounts[i] = rs.getInt(1);
            } catch(Exception e) {
                if(i==0) { 
                     pstmt = conn.prepareStatement("SELECT COUNT(*) FROM member");
                     rs = pstmt.executeQuery();
                     if(rs.next()) memberCounts[0] = rs.getInt(1);
                }
            } finally {
                if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close();
            }
            
            String pSql = "SELECT COUNT(*) FROM Product WHERE 1=1 " + dateConditions[i];
            pstmt = conn.prepareStatement(pSql);
            rs = pstmt.executeQuery();
            if (rs.next()) productCounts[i] = rs.getInt(1);
            if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close();
        }

        // 카테고리별 통계
        for (int i = 0; i < 4; i++) {
            String sql = "SELECT c.category_name, COUNT(p.product_id) as cnt " +
                         "FROM category c " +
                         "LEFT JOIN Product p ON c.category_id = p.category_id " + 
                         "AND 1=1 " + dateConditions[i].replace("WHERE", "AND").replace("created_at", "p.created_at") + " " +
                         "GROUP BY c.category_name";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                categoryStats.get(i).put(rs.getString("category_name"), rs.getInt("cnt"));
            }
            if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 대시보드 - 중고모아</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        /* 기본 설정 */
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f0f2f5; color: #333; }

        /* 헤더 (Header) */
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .header-links a { margin-left: 20px; text-decoration: none; color: #555; font-size: 14px; }
        
        /* 드롭다운 메뉴 */
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }

        /* 메인 레이아웃 */
        .admin-wrapper { flex-grow: 1; display: flex; max-width: 1400px; margin: 20px auto; gap: 20px; width: 100%; min-height: calc(100vh - 200px); }
        .content { flex: 1; padding: 20px; }
        
        /* 사이드바 */
        .admin-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px 0; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); align-self: flex-start; }
        .admin-sidebar h3 { font-size: 16px; color: #2c7be5; padding: 10px 20px; margin-top: 15px; margin-bottom: 5px; border-bottom: 1px solid #eee; }
        .admin-sidebar h3:first-child { margin-top: 0; }
        .admin-sidebar ul { list-style: none; padding: 0; margin: 0; }
        .admin-sidebar li a { display: block; padding: 12px 20px; text-decoration: none; color: #333; font-size: 14px; transition: background-color 0.1s; }
        .admin-sidebar li a:hover { background-color: #f5f5f5; }
        .admin-sidebar li.active a { background-color: #2c7be5; color: white; font-weight: 500; }

        /* 페이지 타이틀 & 카드 통계 */
        .page-header { margin-bottom: 30px; }
        .page-header h2 { font-size: 28px; font-weight: 700; margin: 0; color: #1a1a1a; }
        .page-header p { color: #666; margin-top: 5px; }
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); display: flex; flex-direction: column; justify-content: center; }
        .stat-card h3 { font-size: 14px; color: #888; margin: 0 0 10px 0; font-weight: 500; }
        .stat-card .value { font-size: 28px; font-weight: 700; color: #333; }
        .stat-card .trend { font-size: 13px; margin-top: 5px; color: #2c7be5; }
        .stat-card.highlight { background: linear-gradient(135deg, #2c7be5, #4ca2ff); }
        .stat-card.highlight h3 { color: rgba(255,255,255,0.8); }
        .stat-card.highlight .value { color: white; }
        .stat-card.highlight .trend { color: rgba(255,255,255,0.9); }

        /* 테이블 스타일 */
        .table-container { background: white; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); padding: 25px; margin-bottom: 30px; }
        .section-title { font-size: 18px; font-weight: 700; margin-bottom: 20px; color: #333; border-left: 4px solid #2c7be5; padding-left: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid #eee; font-size: 14px; }
        th { background-color: #f8f9fa; font-weight: 600; color: #555; }
        tr:hover { background-color: #fcfcfc; }
        .category-cell { background-color: #fafafa; color: #444; font-weight: 600; font-size: 14px; text-align: left; padding-left: 30px; }
        .count-today { color: #e03131; font-weight: bold; }
        .count-week { color: #2c7be5; font-weight: bold; }

        /* 푸터 (Footer) */
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }
        .admin-link { font-weight: bold; color: #2c7be5; margin-top: 10px; display: inline-block; }
        .admin-link:hover { text-decoration: underline; }
    </style>
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
            if ((String)session.getAttribute("userId") == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
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
                    background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;"
                />
            <%
            }
            %>
        </div>
    </header>

    <div class="admin-wrapper">
        <nav class="admin-sidebar">
            <h3>회원 관리</h3>
            <ul>
                <li><a href="admin_member_list.jsp">회원 목록</a></li> 
                <li><a href="admin_member_manage.jsp">회원 정지/탈퇴</a></li> 
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
                <li class="active"><a href="admin_page.jsp">전체 통계</a></li> 
            </ul>
        </nav>

        <main class="content">
            <div class="page-header">
                <h2>전체 통계 대시보드</h2>
                <p>사이트의 주요 현황을 한눈에 확인하세요.</p>
            </div>

            <div class="stats-grid">
                <div class="stat-card highlight">
                    <h3>총 회원 수</h3>
                    <div class="value"><%= String.format("%,d", memberCounts[0]) %>명</div>
                    <div class="trend">오늘 가입: +<%= memberCounts[1] %>명</div>
                </div>
                <div class="stat-card">
                    <h3>총 등록 상품</h3>
                    <div class="value"><%= String.format("%,d", productCounts[0]) %>개</div>
                    <div class="trend">오늘 등록: +<%= productCounts[1] %>개</div>
                </div>
                <div class="stat-card">
                    <h3>최근 7일 신규 회원</h3>
                    <div class="value"><%= String.format("%,d", memberCounts[2]) %>명</div>
                </div>
                <div class="stat-card">
                    <h3>최근 7일 등록 상품</h3>
                    <div class="value"><%= String.format("%,d", productCounts[2]) %>개</div>
                </div>
            </div>

            <div class="table-container">
                <div class="section-title">사이트 이용 현황 상세</div>
                <table>
                    <thead>
                        <tr>
                            <th style="width: 200px; text-align: left; padding-left: 30px;">구분</th>
                            <th>전체 누적</th>
                            <th style="color: #e03131;">오늘 (Today)</th>
                            <th style="color: #2c7be5;">최근 1주일</th>
                            <th>최근 1개월</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="category-cell" style="background: #fff;">👥 회원 가입</td>
                            <td><b><%= String.format("%,d", memberCounts[0]) %></b></td>
                            <td class="count-today">+<%= String.format("%,d", memberCounts[1]) %></td>
                            <td class="count-week">+<%= String.format("%,d", memberCounts[2]) %></td>
                            <td>+<%= String.format("%,d", memberCounts[3]) %></td>
                        </tr>
                        <tr>
                            <td class="category-cell" style="background: #fff;">📦 전체 상품 등록</td>
                            <td><b><%= String.format("%,d", productCounts[0]) %></b></td>
                            <td class="count-today">+<%= String.format("%,d", productCounts[1]) %></td>
                            <td class="count-week">+<%= String.format("%,d", productCounts[2]) %></td>
                            <td>+<%= String.format("%,d", productCounts[3]) %></td>
                        </tr>
                        
                        <tr style="border-top: 2px solid #e1e1e1;">
                            <th colspan="5" style="background: #f8f9fa; text-align: left; padding: 15px 30px; color: #2c7be5;">
                                ▼ 카테고리별 상품 등록 현황
                            </th>
                        </tr>
                        
                        <% 
                        if (allCategoryNames.isEmpty()) { 
                        %>
                            <tr><td colspan="5">등록된 카테고리가 없습니다.</td></tr>
                        <% 
                        } else {
                            for (String catName : allCategoryNames) {
                                int total = categoryStats.get(0).getOrDefault(catName, 0);
                                int today = categoryStats.get(1).getOrDefault(catName, 0);
                                int week = categoryStats.get(2).getOrDefault(catName, 0);
                                int month = categoryStats.get(3).getOrDefault(catName, 0);
                        %>
                        <tr>
                            <td class="category-cell"><%= catName %></td>
                            <td style="color: #666;"><%= String.format("%,d", total) %></td>
                            <td class="count-today"><%= today > 0 ? "+" + today : "-" %></td>
                            <td class="count-week"><%= week > 0 ? "+" + week : "-" %></td>
                            <td style="color: #888;"><%= month > 0 ? "+" + month : "-" %></td>
                        </tr>
                        <% 
                            }
                        } 
                        %>
                    </tbody>
                </table>
            </div>
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
                <%
                    String isAdminFooter = (String) session.getAttribute("isAdmin");
                    if (isAdminFooter != null && isAdminFooter.equals("true")) {
                %>
                    <br>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                <%
                    }
                %>
            </div>
        </div>
    </footer>

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
</body>
</html>