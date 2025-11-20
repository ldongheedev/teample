<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    String isAdmin = (String) session.getAttribute("isAdmin");
    String adminName = (String) session.getAttribute("userName");
    
    // 관리자 권한 체크
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>alert("접근 권한이 없습니다."); location.href = "main_page.jsp";</script>
<%
        return;
    }

    // =======================================================
    // 📊 DB 통계 데이터 처리 영역
    // =======================================================
    
    Map<String, Map<String, Object>> statsData = new LinkedHashMap<>();
    
    // DB 연결 정보 (⚠️ 사용자 환경에 맞게 반드시 수정하세요!)
    String url = "jdbc:mariadb://localhost:3308/jspdb";
    String user = "jsp";
    String password = "1234";
    
    // 카테고리 목록
    Map<String, String> categoriesMap = new LinkedHashMap<>();
    categoriesMap.put("clothing", "의류");
    categoriesMap.put("food", "식품");
    categoriesMap.put("accessory", "액세서리");
    categoriesMap.put("digital", "디지털/가전제품");
    categoriesMap.put("sport", "스포츠/레저");
    categoriesMap.put("pet", "애완동물 용품");
    categoriesMap.put("talent", "재능");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        // 기간별 데이터 조회 및 저장
        statsData.put("today", getStats("today", conn, categoriesMap));
        statsData.put("week", getStats("week", conn, categoriesMap));
        statsData.put("month", getStats("month", conn, categoriesMap));

    } catch (Exception e) {
        e.printStackTrace();
        // DB 오류 시 기본값 설정
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("joinerCount", 0);
        errorData.put("forfeitCount", 0);
        errorData.put("judgmentCount", 0);
        errorData.put("regCounts", new HashMap<String, Integer>());
        errorData.put("totalRegCount", 0);
        errorData.put("tradeCompletedCount", 0);
        errorData.put("tradeCanceledCount", 0);
        errorData.put("tradeOngoingCount", 0);
        
        statsData.put("today", errorData);
        statsData.put("week", errorData);
        statsData.put("month", errorData);
        
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<%--
    =======================================================
    <%! ... %> : JSP 선언부 (클래스 레벨 메소드 정의)
    =======================================================
--%>
<%!
    // 기간별 통계 데이터를 가져오는 함수 (선언부에서 정의)
    Map<String, Object> getStats(String period, Connection conn, Map<String, String> categoriesMap) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        String productDateCondition;
        String memberDateCondition;
        String logDateCondition; // sanction_log용 조건

        switch (period) {
            case "today":
                productDateCondition = "DATE(reg_date) = CURDATE()";
                memberDateCondition = "DATE(join_date) = CURDATE()";
                logDateCondition = "DATE(reg_date) = CURDATE()"; 
                break;
            case "week":
                productDateCondition = "YEARWEEK(reg_date, 1) = YEARWEEK(CURDATE(), 1)";
                memberDateCondition = "YEARWEEK(join_date, 1) = YEARWEEK(CURDATE(), 1)";
                logDateCondition = "YEARWEEK(reg_date, 1) = YEARWEEK(CURDATE(), 1)"; 
                break;
            case "month":
                productDateCondition = "YEAR(reg_date) = YEAR(CURDATE()) AND MONTH(reg_date) = MONTH(CURDATE())";
                memberDateCondition = "YEAR(join_date) = YEAR(CURDATE()) AND MONTH(join_date) = MONTH(CURDATE())";
                logDateCondition = "YEAR(reg_date) = YEAR(CURDATE()) AND MONTH(reg_date) = MONTH(CURDATE())"; 
                break;
            default:
                return data;
        }
        
        // --- 1-1. 가입자 수 통계 (member 테이블 사용) ---
        String memberSql = "SELECT COUNT(*) FROM member WHERE " + memberDateCondition;
        try (Statement stmt = conn.createStatement(); ResultSet rsMember = stmt.executeQuery(memberSql)) {
            if (rsMember.next()) {
                data.put("joinerCount", rsMember.getInt(1));
            } else { data.put("joinerCount", 0); }
        }

        // --- 1-2. 선취금/선고금 통계 (sanction_log 테이블 사용) ---
        String forfeitSql = "SELECT COUNT(*) FROM sanction_log WHERE type = 'FORFEIT' AND " + logDateCondition;
        String judgmentSql = "SELECT COUNT(*) FROM sanction_log WHERE type = 'JUDGMENT' AND " + logDateCondition;
        
        try (Statement stmt = conn.createStatement(); ResultSet rsForfeit = stmt.executeQuery(forfeitSql)) {
            if (rsForfeit.next()) { data.put("forfeitCount", rsForfeit.getInt(1)); } else { data.put("forfeitCount", 0); }
        }
        try (Statement stmt = conn.createStatement(); ResultSet rsJudgment = stmt.executeQuery(judgmentSql)) {
            if (rsJudgment.next()) { data.put("judgmentCount", rsJudgment.getInt(1)); } else { data.put("judgmentCount", 0); }
        }

        // --- 2. 게시글 수 (상품 등록 수) 카테고리별 통계 (product 테이블 사용) ---
        Map<String, Integer> regCounts = new HashMap<>();
        int totalRegCount = 0;
        String regSql = "SELECT category, COUNT(*) FROM product WHERE " + productDateCondition + " GROUP BY category"; 
        
        try (PreparedStatement regPstmt = conn.prepareStatement(regSql); ResultSet rsReg = regPstmt.executeQuery()) {
            while (rsReg.next()) {
                String category = rsReg.getString("category");
                int count = rsReg.getInt(2);
                regCounts.put(category, count); 
                totalRegCount += count;
            }
        }
        data.put("regCounts", regCounts);
        data.put("totalRegCount", totalRegCount);
        
        // --- 3. 거래 건수 통계 (product 테이블 사용) ---
        int tradeCompletedCount = 0;
        int tradeCanceledCount = 0;
        int tradeOngoingCount = 0;

        String tradeSql = "SELECT trade_status, COUNT(*) FROM product WHERE " + productDateCondition + " GROUP BY trade_status";
        try (PreparedStatement tradePstmt = conn.prepareStatement(tradeSql); ResultSet rsTrade = tradePstmt.executeQuery()) {
            while (rsTrade.next()) {
                String status = rsTrade.getString("trade_status");
                int count = rsTrade.getInt(2);
                if ("COMPLETED".equalsIgnoreCase(status)) {
                    tradeCompletedCount = count;
                } else if ("CANCELED".equalsIgnoreCase(status)) {
                    tradeCanceledCount = count;
                } else if ("SALE".equalsIgnoreCase(status)) {
                    tradeOngoingCount = count;
                }
            }
        }
        data.put("tradeCompletedCount", tradeCompletedCount);
        data.put("tradeCanceledCount", tradeCanceledCount);
        data.put("tradeOngoingCount", tradeOngoingCount);

        return data;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 전체 통계</title>
    <style>
        /* [핵심 수정] Sticky Footer를 위한 기본 설정 */
        html, body { height: 100%; margin: 0; }
        body { 
            font-family: 'Noto Sans KR', sans-serif; 
            background-color: #f9f9f9; 
            color: #333; 
            display: flex;
            flex-direction: column;
        }
        a { text-decoration: none; color: inherit; }
        ul { list-style: none; padding: 0; margin: 0; }

        /* [고정] 상단 헤더 */
        header { 
            flex-shrink: 0;
            display: flex; justify-content: space-between; align-items: center; 
            padding: 10px 40px; background-color: #ffffff; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.05); 
        }
        .logo img { height: 40px; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .dropdown-content.show { display: block; }
        
        /* 관리자 페이지 레이아웃 */
        .admin-wrapper { 
            flex-grow: 1; 
            display: flex; max-width: 1400px; 
            margin: 20px auto; gap: 20px; 
            width: 100%; 
        }
        .admin-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px 0; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); align-self: flex-start; }
        .admin-sidebar h3 { font-size: 16px; color: #2c7be5; padding: 10px 20px; margin-top: 15px; margin-bottom: 5px; border-bottom: 1px solid #eee; }
        .admin-sidebar ul { list-style: none; padding: 0; margin: 0; }
        .admin-sidebar li a { display: block; padding: 12px 20px; text-decoration: none; color: #333; font-size: 14px; transition: background-color 0.1s; }
        .admin-sidebar li a:hover { background-color: #f5f5f5; }
        .admin-sidebar li.active a { background-color: #2c7be5; color: white; font-weight: 500; }
        
        .admin-content { 
            flex-grow: 1; 
            background-color: #ffffff; padding: 30px 40px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; 
        }
        .admin-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 30px; }
        .admin-header h2 { font-size: 24px; margin: 0; }
        
        /* --- 통계 대시보드 전용 스타일 --- */
        .stats-section {
            margin-bottom: 40px; border: 1px solid #eee; padding: 25px; border-radius: 8px; background-color: #fff;
        }
        .stats-section h3 {
            font-size: 18px; font-weight: 700; margin-top: 15px; margin-bottom: 15px; color: #333; padding-bottom: 10px; border-bottom: 1px solid #eee;
        }
        
        /* 탭 버튼 그룹 스타일 */
        .stats-tabs {
            display: flex; 
            margin-bottom: 5px; 
            padding: 5px 0;
            background-color: #f7f7f7; 
            border-radius: 5px;
        }
        
        /* 탭 버튼 클릭 시 색상 변경 스타일 */
        .stats-tabs button {
            background-color: transparent; 
            border: none; 
            padding: 8px 15px; 
            cursor: pointer; 
            font-size: 15px; 
            font-weight: 500; 
            color: #666; 
            transition: color 0.2s, background-color 0.2s;
        }
        .stats-tabs button.active {
            color: #2c7be5; 
            font-weight: 700;
            background-color: #e6f0ff; 
            border-radius: 5px;
        }
        
        /* 그리드 카드 레이아웃 */
        .card-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 10px 0;
        }
        .stat-card-item h4 {
            font-size: 14px; color: #666; margin: 0 0 5px 0; font-weight: 400;
        }
        .stat-card-item strong {
            font-size: 22px; font-weight: 700; color: #333;
        }
        .stat-card-item span {
            font-size: 13px; color: #888; margin-left: 5px;
        }

        /* 통계표 레이아웃 */
        .stat-table-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 15px;
        }
        .stat-table {
            border: 1px solid #eee; border-radius: 5px; background-color: #fff; padding: 20px;
        }
        .stat-table h4 {
            font-size: 16px; font-weight: 700; margin: 0 0 15px 0; color: #333; border-bottom: 2px solid #ddd; padding-bottom: 5px;
        }
        .stat-table ul {
            padding: 0; margin: 0;
        }
        .stat-table li {
            display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #eee; font-size: 14px; color: #555;
        }
        .stat-table .total-row {
            padding-top: 15px; border-top: 2px solid #999; font-weight: 700; color: #333; font-size: 15px;
        }

        /* --- 푸터 스타일 (원복) --- */
        footer {
            /* 원복된 색상 */
            background-color: #f1f1f1; 
            padding: 40px;
            /* 관리자 페이지 레이아웃에 맞게 조정 */
            flex-shrink: 0;
            width: 100%;
            margin-top: 40px;
            display: flex;
            justify-content: center;
        }
        .footer-content-wrapper { 
            display: flex;
            max-width: 1400px;
            width: 100%;
            padding: 0 40px;
            gap: 80px;
            justify-content: space-between;
        }
        .footer-info {
            flex-shrink: 0;
            max-width: 350px;
        }
        .footer-section h4 {
            font-size: 16px; font-weight: 700; margin-top: 0; margin-bottom: 15px; color: #333; 
        }
        .footer-section p, .footer-section a {
            margin: 5px 0; font-size: 13px; color: #555; 
            line-height: 1.6; display: block;
        }
        .footer-section img {
            margin-bottom: 15px;
            object-fit: contain;
        }
        .footer-links {
            display: flex;
            gap: 40px;
        }
        
        /* 탭 컨텐츠의 초기 상태를 숨김으로 설정하는 CSS 클래스 */
        .tab-content {
            display: none;
        }
    </style>

    <script>
        function toggleDropdown(event) {
            event.stopPropagation();
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
        
        // 🚨 [수정된 showTab] 탭 기능: 클릭 시 해당 섹션의 탭 버튼 활성화 및 내용 표시
        function showTab(sectionId, tabName) {
            
            const section = document.getElementById(sectionId);
            if (!section) return;

            // 1. 탭 버튼 상태 관리
            const tabs = section.querySelectorAll('.stats-tabs button');
            tabs.forEach(tab => tab.classList.remove('active'));
            
            // data-tab 속성을 가진 버튼만 찾아서 활성화
            const activeTabButton = section.querySelector(`.stats-tabs button[data-tab='${tabName}']`);
            if (activeTabButton) {
                activeTabButton.classList.add('active'); 
            }

            // 2. 탭 내용 상태 관리
            const contents = section.querySelectorAll('.tab-content');
            contents.forEach(content => {
                // 모든 탭 내용을 숨김
                content.style.display = 'none';
            });
            
            // 선택된 탭 내용만 표시 (클래스 이름으로 찾기)
            const activeContent = section.querySelector(`.tab-content.${tabName}`);
            if (activeContent) {
                activeContent.style.display = 'block';
            }
        }

        // 🚨 [수정된 초기화] 초기 로드 시 '오늘' 탭 활성화
        document.addEventListener('DOMContentLoaded', () => {
             // 'access-stats' 섹션의 'today' 탭을 자동으로 활성화
            showTab('access-stats', 'today'); 
        });
    </script>
</head>
<body>
    
    <header>
        <div class="logo"><a href="main_page.jsp"><img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;"></a></div>
        <div class="header-links">
            <div class="welcome-message">관리자 <%= adminName %>님, 환영합니다.</div>
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown(event)">
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
        
        <main class="admin-content">
            <div class="admin-header">
                <h2>전체 통계</h2>
            </div>
            
            <%
                String[] periods = {"today", "week", "month"};
                String[] periodLabels = {"오늘", "이번주", "이번달"};
            %>
            
            <div class="stats-section" id="access-stats">
                
                <div class="stats-tabs">
                    <% for(int i=0; i<periods.length; i++) { %>
                        <button type="button" data-tab="<%= periods[i] %>" onclick="showTab('access-stats', '<%= periods[i] %>')"><%= periodLabels[i] %></button>
                    <% } %>
                </div>
                
                <h3>가입 및 제재 통계</h3>
                
                <% for(int i=0; i<periods.length; i++) { 
                    String periodKey = periods[i];
                    Map<String, Object> data = statsData.get(periodKey);
                    
                    int joinerCount = (Integer) data.get("joinerCount");
                    int forfeitCount = (Integer) data.get("forfeitCount");
                    int judgmentCount = (Integer) data.get("judgmentCount");
                %>
                    <div class="tab-content <%= periodKey %>"> 
                        <div class="card-grid">
                            <div class="stat-card-item">
                                <h4>신규 가입자 수</h4>
                                <strong><%= joinerCount %></strong><span>명</span>
                            </div>
                             <div class="stat-card-item">
                                <h4>선취금 발행 수</h4>
                                <strong><%= forfeitCount %></strong><span>개</span>
                            </div>
                            <div class="stat-card-item">
                                <h4>선고금 발행 수</h4>
                                <strong><%= judgmentCount %></strong><span>개</span>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>

            
            <% 
                Map<String, Object> todayData = statsData.getOrDefault("today", new HashMap<>());
                Map<String, Integer> regCounts = (Map<String, Integer>) todayData.getOrDefault("regCounts", new HashMap<String, Integer>());
                int totalRegCount = (Integer) todayData.getOrDefault("totalRegCount", 0);
                int tradeCompletedCount = (Integer) todayData.getOrDefault("tradeCompletedCount", 0);
                int tradeCanceledCount = (Integer) todayData.getOrDefault("tradeCanceledCount", 0);
                int tradeOngoingCount = (Integer) todayData.getOrDefault("tradeOngoingCount", 0);
            %>
            <div class="stats-section" id="product-stats">
                <h3>게시글 및 거래 통계 (오늘)</h3>
                <div class="stat-table-grid">
                    <div class="stat-table">
                        <h4>상품 등록 수</h4>
                        <ul>
                            <% 
                                for(Map.Entry<String, String> entry : categoriesMap.entrySet()) {
                                    String categoryCode = entry.getKey(); 
                                    String categoryName = entry.getValue();
                                    int count = regCounts.getOrDefault(categoryCode, 0); 
                            %>
                                <li><span class="label"><%= categoryName %> 상품 등록수</span><span class="value"><%= count %>개</span></li>
                            <% } %>
                            <li class="total-row"><span class="label">오늘 등록된 총 상품</span><span class="value"><%= totalRegCount %>개</span></li>
                        </ul>
                    </div>
                    <div class="stat-table">
                        <h4>거래 건수</h4>
                        <ul>
                            <li><span class="label">거래 완료 건수</span><span class="value"><%= tradeCompletedCount %>개</span></li>
                            <li><span class="label">거래 취소 건수</span><span class="value"><%= tradeCanceledCount %>개</span></li>
                            <li><span class="label">거래 중</span><span class="value"><%= tradeOngoingCount %>개</span></li>
                        </ul>
                    </div>
                </div>
            </div>

        </main>
    </div>

    <footer>
        <div class="footer-content-wrapper">
            <div class="footer-section footer-info">
                <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; object-fit: contain;"/>
                <p>(주) 중고모아 | 대표 김령균</p>
                <p>TEL : 010-0000-0000</p>
                <p>Mail : junggomoa@gmail.com</p>
                <p>주소 : 경기도 xx시 xx구 xx로 xx번</p>
                <p>이용약관 / 개인정보처리방침</p>
            </div>
            <div class="footer-links">
                <div class="footer-section">
                    <h4>ABOUT</h4>
                    <a href="company_intro.jsp"> 회사소개 </a>
                    <a href="notice_list.jsp"> 공지사항 </a>
                </div>
                <div class="footer-section">
                    <h4>SUPPORT</h4>
                    <a href="inquiry_list.jsp"> 1:1 문의 </a>
                    <a href="faq_list.jsp"> FAQ </a>
                    <a href="admin_page.jsp" class="admin-link">관리자 페이지</a>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>