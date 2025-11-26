<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLDecoder" %>

<%
    // 1. 로그인 체크
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
    
    // 포맷터
    DecimalFormat formatter = new DecimalFormat("#,###");

    // =========================================================
    // 2. [수정됨] 최근 본 상품 쿠키 가져오기 (사용자 ID 전용)
    // =========================================================
    
    // 현재 로그인한 사용자의 ID가 붙은 쿠키 이름만 찾습니다.
    String recentCookieName = "recent_products_" + userId;
    
    String recentProps = "";
    Cookie[] cookies = request.getCookies();
    List<String> recentIds = new ArrayList<>();
    
    if (cookies != null) {
        for (Cookie c : cookies) {
            // 이름이 정확히 내 ID와 일치하는 쿠키만 가져옴
            if (c.getName().equals(recentCookieName)) {
                recentProps = URLDecoder.decode(c.getValue(), "UTF-8");
                break;
            }
        }
    }
    
    if (!recentProps.isEmpty()) {
        String[] ids = recentProps.split("/");
        for (String s : ids) {
            if(!s.isEmpty()) recentIds.add(s);
        }
    }
    // =========================================================
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 중고모아</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

        /* [Header] 스타일 (기존 유지) */
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .header-links a { margin-left: 20px; text-decoration: none; color: #555; font-size: 14px; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }

        /* ==================== [요청하신 사이드바 및 레이아웃 CSS] ==================== */
        .mypage-wrapper { display: flex; max-width: 1400px; min-height: 70vh; margin: 20px auto; gap: 20px; }
        .mypage-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; height: fit-content; }
        .mypage-sidebar h3 { font-size: 18px; color: #333; margin-top: 0; margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .mypage-sidebar ul { list-style: none; padding: 0; margin: 0 0 20px 0; }
        .mypage-sidebar li a { display: block; padding: 12px 15px; text-decoration: none; color: #555; font-size: 15px; border-radius: 6px; }
        .mypage-sidebar li a:hover { background-color: #f5f5f5; }
        .mypage-sidebar li.active a { background-color: #81c147; color: white; font-weight: 500; }
        .mypage-content { flex-grow: 1; background-color: #ffffff; padding: 30px 40px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; }
        .mypage-content h2 { font-size: 24px; margin-top: 0; margin-bottom: 25px; border-bottom: 2px solid #333; padding-bottom: 10px; }
        /* ========================================================================= */

        /* [콘텐츠 내부 스타일 - 상품 목록 카드 등] */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; margin-top: 30px; }
        .section-header h3 { font-size: 18px; font-weight: 700; color: #555; margin: 0; }
        .section-header:first-of-type { margin-top: 0; }

        /* 상품 그리드 */
        .product-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
        .product-item { border: 1px solid #eee; border-radius: 8px; overflow: hidden; transition: 0.3s; background: white; }
        .product-item:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .p-img { width: 100%; height: 150px; background-color: #f9f9f9; overflow: hidden; }
        .p-img img { width: 100%; height: 100%; object-fit: cover; }
        .p-info { padding: 12px; }
        .p-title { font-size: 14px; font-weight: 500; margin-bottom: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .p-price { font-size: 15px; font-weight: 700; color: #2c7be5; }
        
        /* 최근 본 상품 (가로 스크롤) */
        .recent-list-wrapper { display: flex; gap: 15px; overflow-x: auto; padding-bottom: 10px; }
        .recent-item { min-width: 140px; width: 140px; border: 1px solid #eee; border-radius: 8px; overflow: hidden; background: white; }
        .recent-item .p-img { height: 120px; }
        .empty-msg { width: 100%; text-align: center; padding: 30px; color: #999; font-size: 14px; grid-column: span 4; background-color: #fcfcfc; border-radius: 8px; }

        /* Footer */
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; margin-top: 40px; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }
        .admin-link { font-weight: bold; color: #2c7be5; margin-top: 10px; display: inline-block; }
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
        </div>
    </header>

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
                <li><a href="trade_list.jsp">거래조회</a></li>
            </ul>
            <h3>상품관리</h3>
            <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li class="active"><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
            <h3>고객센터</h3>
            <ul>
                <li><a href="inquiry_list.jsp">1:1 문의</a></li>
                <li><a href="faq_list.jsp">FAQ</a></li>
            </ul>
        </nav>

        <div class="mypage-content">
            <h2>내 상점 관리</h2>
            
            <div class="section-header">
                <h3>등록한 상품 목록</h3>
                <a href="product_add_form.jsp" style="font-size: 13px; color: #2c7be5; font-weight: bold; text-decoration: none;">+ 상품 등록 바로가기</a>
            </div>
            
            <div class="product-grid">
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                    
                    // 내 상품 조회 (최신순 4개)
                    String sql = "SELECT * FROM Product WHERE user_id = ? ORDER BY created_at DESC LIMIT 4";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, userId);
                    rs = pstmt.executeQuery();
                    
                    boolean hasProduct = false;
                    while (rs.next()) {
                        hasProduct = true;
                        int pId = rs.getInt("product_id");
                        String pName = rs.getString("product_name");
                        int pPrice = rs.getInt("price");
                        String pImg = rs.getString("main_image_url");
                %>
                    <div class="product-item">
                        <a href="product_detail.jsp?product_id=<%= pId %>" style="text-decoration: none; color: inherit;">
                            <div class="p-img">
                                <img src="<%= request.getContextPath() + pImg %>" alt="<%= pName %>">
                            </div>
                            <div class="p-info">
                                <div class="p-title"><%= pName %></div>
                                <div class="p-price"><%= formatter.format(pPrice) %>원</div>
                                <div style="margin-top: 5px; font-size: 12px; text-align: right;">
                                    <a href="product_edit.jsp?product_id=<%= pId %>" style="color: #666;">수정</a> | 
                                    <a href="product_delete_form.jsp?product_id=<%= pId %>" style="color: #e03131;">삭제</a>
                                </div>
                            </div>
                        </a>
                    </div>
                <%
                    }
                    if (!hasProduct) {
                %>
                    <div class="empty-msg">등록된 상품이 없습니다.</div>
                <%
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                } finally {
                    if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close();
                    if(conn!=null) conn.close(); 
                }
                %>
            </div>

            <div class="section-header">
                <h3>최근 본 상품</h3>
                <span style="font-size: 12px; color: #888;">(최대 5개)</span>
            </div>
            
            <div class="recent-list-wrapper">
                <%
                if (recentIds.isEmpty()) {
                %>
                    <div class="empty-msg">최근 본 상품 내역이 없습니다.</div>
                <%
                } else {
                    try {
                        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                        
                        // IN (?,?,?...) 동적 쿼리
                        StringBuilder sqlBuilder = new StringBuilder("SELECT product_id, product_name, price, main_image_url FROM Product WHERE product_id IN (");
                        for(int i=0; i<recentIds.size(); i++) {
                            sqlBuilder.append(i == 0 ? "?" : ",?");
                        }
                        sqlBuilder.append(") ORDER BY FIELD(product_id, ");
                        for(int i=0; i<recentIds.size(); i++) {
                            sqlBuilder.append(i == 0 ? "?" : ",?");
                        }
                        sqlBuilder.append(")");
                        
                        pstmt = conn.prepareStatement(sqlBuilder.toString());
                        
                        int idx = 1;
                        for(String s : recentIds) pstmt.setInt(idx++, Integer.parseInt(s));
                        for(String s : recentIds) pstmt.setInt(idx++, Integer.parseInt(s));
                        
                        rs = pstmt.executeQuery();
                        
                        while(rs.next()) {
                            int rId = rs.getInt("product_id");
                            String rName = rs.getString("product_name");
                            int rPrice = rs.getInt("price");
                            String rImg = rs.getString("main_image_url");
                %>
                    <div class="recent-item">
                        <a href="product_detail.jsp?product_id=<%= rId %>" style="text-decoration: none; color: inherit;">
                            <div class="p-img">
                                <img src="<%= request.getContextPath() + rImg %>" alt="<%= rName %>">
                            </div>
                            <div class="p-info">
                                <div class="p-title"><%= rName %></div>
                                <div class="p-price"><%= formatter.format(rPrice) %>원</div>
                            </div>
                        </a>
                    </div>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        if(rs!=null) rs.close(); if(pstmt!=null) pstmt.close(); if(conn!=null) conn.close();
                    }
                }
                %>
            </div>

        </div>
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
        
        // 토스트 메시지 처리
        <%
            String toastMsg = (String) session.getAttribute("toastMessage");
            if (toastMsg != null) {
                session.removeAttribute("toastMessage");
        %>
            alert("<%= toastMsg %>");
        <%
            }
        %>
    </script>
</body>
</html>