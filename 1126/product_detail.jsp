<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedList" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>

<%
    // 1. 사용자 세션 확인
    String currentUserId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    
    // 2. 상품 ID 파라미터 받기
    String productIdStr = request.getParameter("product_id");
    
    if (productIdStr == null) {
        out.println("<script>alert('상품 ID가 없습니다.'); history.back();</script>");
        return;
    }
    
    int productId = Integer.parseInt(productIdStr);

    // =================================================================
    // 🍪 최근 본 상품 쿠키 저장 로직
    // =================================================================
    String cookieUserId = (currentUserId != null) ? currentUserId : "guest";
    String recentCookieName = "recent_products_" + cookieUserId;
    
    String recentProps = "";
    
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if (c.getName().equals(recentCookieName)) {
                recentProps = URLDecoder.decode(c.getValue(), "UTF-8");
                break;
            }
        }
    }

    LinkedList<String> recentList = new LinkedList<>();
    if (!recentProps.isEmpty()) {
        String[] ids = recentProps.split("/");
        for (String s : ids) {
            if (!s.isEmpty()) recentList.add(s);
        }
    }

    String currentIdStr = String.valueOf(productId);

    recentList.remove(currentIdStr);
    recentList.addFirst(currentIdStr);

    if (recentList.size() > 5) {
        recentList.removeLast();
    }

    String newRecentProps = String.join("/", recentList);
    Cookie newCookie = new Cookie(recentCookieName, URLEncoder.encode(newRecentProps, "UTF-8"));
    newCookie.setMaxAge(60 * 60 * 24); 
    newCookie.setPath("/"); 
    response.addCookie(newCookie);
    // =================================================================


    // 3. DB 연결 및 상품 정보 조회
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String pName = "", pDesc = "", pMainImg = "", pCategory = "", pSellerNick = "", pSellerPhone = "";
    String pSellerAddr = ""; // 지도 표시용 판매자 주소
    int pPrice = 0;
    boolean pIsSoldOut = false;
    String pCreatedAt = "";
    
    ArrayList<String> detailImages = new ArrayList<>();
    String pSellerId = null;
    
    boolean isWished = false; // 찜 여부
    String tradeStatus = null; // 거래 요청 상태

    DecimalFormat formatter = new DecimalFormat("#,###");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");

        // (1) 상품 기본 정보 + 판매자 정보(주소 포함) 조회
        String sql = "SELECT p.*, m.nickname, m.phone, m.addr_base, c.category_name " +
                     "FROM Product p " +
                     "JOIN member m ON p.user_id = m.id " +
                     "JOIN category c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            pSellerId = rs.getString("user_id");
            pName = rs.getString("product_name");
            pDesc = rs.getString("description");
            pPrice = rs.getInt("price");
            pMainImg = rs.getString("main_image_url");
            pCategory = rs.getString("category_name");
            pSellerNick = rs.getString("nickname");
            pSellerPhone = rs.getString("phone");
            pSellerAddr = rs.getString("addr_base"); // 주소 가져오기
            pIsSoldOut = rs.getBoolean("is_sold_out");
            pCreatedAt = rs.getString("created_at").substring(0, 16); 
        } else {
            out.println("<script>alert('존재하지 않는 상품입니다.'); history.back();</script>");
            return;
        }
        rs.close();
        pstmt.close();

        // (2) 상세 이미지 조회
        String imgSql = "SELECT image_url FROM ProductImage WHERE product_id = ? ORDER BY display_order ASC";
        pstmt = conn.prepareStatement(imgSql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            detailImages.add(rs.getString("image_url"));
        }
        rs.close();
        pstmt.close();
        
        // (3) 찜 여부 확인
        if (currentUserId != null) {
            String wishSql = "SELECT 1 FROM Wishlist WHERE user_id = ? AND product_id = ?";
            pstmt = conn.prepareStatement(wishSql);
            pstmt.setString(1, currentUserId);
            pstmt.setInt(2, productId);
            rs = pstmt.executeQuery();
            if (rs.next()) isWished = true;
            rs.close();
            pstmt.close();
            
            // (4) 거래 요청 상태 확인
            String tradeSql = "SELECT status FROM TradeRequest WHERE product_id = ? AND buyer_id = ?";
            pstmt = conn.prepareStatement(tradeSql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, currentUserId);
            rs = pstmt.executeQuery();
            if (rs.next()) tradeStatus = rs.getString("status");
            rs.close();
            pstmt.close();
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if (conn != null) try { conn.close(); } catch(SQLException ex) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= pName %> - 중고모아</title>
    
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>

    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=bcc79fb201a4c981b39abe52461abf5b&libraries=services"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

        /* ==================== [헤더 스타일] ==================== */
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

        /* ==================== [상품 상세 스타일] ==================== */
        .product-detail-container { max-width: 1000px; margin: 40px auto; display: flex; gap: 40px; }
        
        /* 왼쪽: 이미지 영역 */
        .image-section { flex: 1; width: 500px; }
        .swiper-container { width: 100%; height: 400px; border-radius: 10px; overflow: hidden; border: 1px solid #eee; }
        .swiper-slide img { width: 100%; height: 100%; object-fit: cover; }
        .swiper-pagination { color: #2c7be5; }

        /* 오른쪽: 정보 영역 */
        .info-section { flex: 1; display: flex; flex-direction: column; justify-content: flex-start; }
        .category-badge { display: inline-block; background-color: #eef1f6; color: #2c7be5; padding: 5px 10px; border-radius: 4px; font-size: 13px; font-weight: bold; margin-bottom: 15px; width: fit-content; }
        .product-title { font-size: 28px; font-weight: 700; margin-bottom: 10px; line-height: 1.4; }
        .product-price { font-size: 32px; font-weight: 700; color: #2c7be5; margin-bottom: 20px; }
        
        .product-meta { border-top: 1px solid #eee; border-bottom: 1px solid #eee; padding: 20px 0; margin-bottom: 20px; }
        .meta-row { display: flex; margin-bottom: 10px; font-size: 14px; }
        .meta-label { width: 100px; color: #888; }
        .meta-value { color: #333; font-weight: 500; }
        
        /* 버튼 영역 */
        .action-buttons { display: flex; gap: 10px; margin-top: auto; }
        .btn { flex: 1; padding: 15px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.2s; text-align: center; text-decoration: none; display: inline-flex; justify-content: center; align-items: center; }
        
        .btn-trade { background-color: #2c7be5; color: white; }
        .btn-trade:hover { background-color: #1a68d1; }
        .btn-trade:disabled { background-color: #ccc; cursor: not-allowed; }
        
        .btn-wish { background-color: white; border: 1px solid #ddd; color: #333; display: flex; align-items: center; justify-content: center; gap: 5px; }
        .btn-wish.active { border-color: #ff4d4d; color: #ff4d4d; }
        .btn-wish:hover { background-color: #f9f9f9; }
        
        .btn-edit { background-color: #f1f3f5; color: #333; }
        .btn-delete { background-color: #ffeaea; color: #e03131; }

        /* ==================== [탭 & 하단 콘텐츠 스타일] ==================== */
        .tab-container { max-width: 1000px; margin: 0 auto 60px; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); overflow: hidden; }
        .tab-menu { display: flex; border-bottom: 1px solid #eee; }
        .tab-btn { flex: 1; padding: 20px; text-align: center; cursor: pointer; font-size: 16px; font-weight: bold; color: #888; background: #fcfcfc; transition: 0.2s; border: none; border-bottom: 2px solid transparent; }
        .tab-btn:hover { background: #f5f5f5; }
        .tab-btn.active { background: #fff; color: #2c7be5; border-bottom: 2px solid #2c7be5; }
        
        /* 탭 내용 영역 */
        .tab-content { display: none; padding: 40px; min-height: 300px; }
        .tab-content.active { display: block; }
        
        .desc-content { white-space: pre-wrap; line-height: 1.6; color: #444; font-size: 16px; }
        
        /* 지도 관련 */
        .map-title { font-size: 18px; font-weight: 700; margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
        .addr-text { font-size: 14px; color: #2c7be5; background: #eef1f6; padding: 4px 8px; border-radius: 4px; font-weight: normal; }
        #map { width: 100%; height: 400px; border-radius: 8px; border: 1px solid #ddd; background-color: #eee; }

        /* ==================== [푸터 스타일] ==================== */
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
            if (currentUserId == null) {
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

    <div class="product-detail-container">
        <div class="image-section">
            <div class="swiper-container">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <img src="<%= request.getContextPath() + pMainImg %>" alt="<%= pName %>">
                    </div>
                    <% for(String img : detailImages) { %>
                        <div class="swiper-slide">
                            <img src="<%= request.getContextPath() + img %>" alt="상세이미지">
                        </div>
                    <% } %>
                </div>
                <div class="swiper-pagination"></div>
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
            </div>
        </div>

        <div class="info-section">
            <div class="category-badge"><%= pCategory %></div>
            <h1 class="product-title"><%= pName %></h1>
            <div class="product-price">
                <% if (pIsSoldOut) { %>
                    <span style="color: #999; text-decoration: line-through;"><%= formatter.format(pPrice) %>원</span>
                    <span style="color: #e03131; font-size: 24px; margin-left: 10px;">(판매완료)</span>
                <% } else { %>
                    <%= formatter.format(pPrice) %>원
                <% } %>
            </div>

            <div class="product-meta">
                <div class="meta-row">
                    <span class="meta-label">판매자</span>
                    <span class="meta-value"><%= pSellerNick %></span>
                </div>
                <div class="meta-row">
                    <span class="meta-label">연락처</span>
                    <span class="meta-value"><%= pSellerPhone != null ? pSellerPhone : "비공개" %></span>
                </div>
                <div class="meta-row">
                    <span class="meta-label">등록일</span>
                    <span class="meta-value"><%= pCreatedAt %></span>
                </div>
                <div class="meta-row">
                    <span class="meta-label">주소</span>
                    <span class="meta-value"><%= (pSellerAddr != null && !pSellerAddr.trim().isEmpty()) ? pSellerAddr : "미등록" %></span>
                </div>
            </div>

            <div class="action-buttons">
                <% 
                // 1. 판매자 본인인 경우 -> 수정/삭제 버튼
                if (currentUserId != null && currentUserId.equals(pSellerId)) { 
                %>
                    <a href="product_edit.jsp?product_id=<%= productId %>" class="btn btn-edit">상품 정보 수정</a>
                    <a href="javascript:void(0);" onclick="confirmDelete()" class="btn btn-delete">삭제하기</a>
                <% 
                // 2. 판매자가 아닌 경우 -> 거래요청/찜하기 버튼
                } else { 
                    boolean isAlreadyRequested = "REQUESTED".equals(tradeStatus) || "ACCEPTED".equals(tradeStatus);
                %>
                    <% if (pIsSoldOut) { %>
                        <button class="btn btn-trade" disabled>판매 완료된 상품입니다</button>
                    <% } else if (isAlreadyRequested) { %>
                        <button class="btn btn-trade" disabled>이미 거래 요청 중입니다</button>
                    <% } else { %>
                        <button id="btnRequestTrade" class="btn btn-trade">거래 요청하기 (채팅)</button>
                    <% } %>

                    <button id="btnToggleWish" class="btn btn-wish <%= isWished ? "active" : "" %>">
                        <%= isWished ? "♥ 찜 취소" : "♡ 찜하기" %>
                    </button>
                <% } %>
            </div>
        </div>
    </div>

    <div class="tab-container">
        <div class="tab-menu">
            <button class="tab-btn active" onclick="openTab('desc')">상품 상세 설명</button>
            <button class="tab-btn" onclick="openTab('map')">거래 희망 장소 (지도)</button>
        </div>

        <div id="tab-desc" class="tab-content active">
            <div class="desc-content"><%= pDesc %></div>
            <% if (!detailImages.isEmpty()) { %>
                <div style="margin-top: 30px; text-align: center;">
                    <p style="color: #888; margin-bottom: 10px;">- 상세 이미지 -</p>
                    <% for(String img : detailImages) { %>
                        <img src="<%= request.getContextPath() + img %>" style="max-width: 100%; margin-bottom: 20px; border-radius: 8px;">
                    <% } %>
                </div>
            <% } %>
        </div>

        <div id="tab-map" class="tab-content">
            <div class="map-title">
                📍 거래 희망 장소
                <span class="addr-text">
                    <%= (pSellerAddr != null && !pSellerAddr.trim().isEmpty()) ? pSellerAddr : "주소 미등록" %>
                </span>
            </div>
            <div id="map"></div>
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
                <a href="inquiry_list.jsp"> <%= question %> </a><br>
                <a href="faq_list.jsp"> <%= faq %> </a>
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

    <script>
        // --- 1. 전역 변수 (지도 객체) ---
        var map = null;
        var mapCenterCoords = null;

        // --- 2. UI 동작 ---
        function toggleDropdown() {
            document.getElementById("myDropdown").classList.toggle("show");
        }
        window.onclick = function(e) {
            if (!e.target.matches('.dropdown-toggle')) {
                var dropdowns = document.getElementsByClassName("dropdown-content");
                for (var i = 0; i < dropdowns.length; i++) {
                    if (dropdowns[i].classList.contains('show')) dropdowns[i].classList.remove('show');
                }
            }
        }
        new Swiper('.swiper-container', { loop: true, pagination: { clickable: true }, navigation: { nextEl: '.swiper-button-next', prevEl: '.swiper-button-prev' } });

        // --- 3. 탭 전환 함수 ---
        function openTab(tabName) {
            var contents = document.getElementsByClassName("tab-content");
            for (var i = 0; i < contents.length; i++) {
                contents[i].classList.remove("active");
            }
            var btns = document.getElementsByClassName("tab-btn");
            for (var i = 0; i < btns.length; i++) {
                btns[i].classList.remove("active");
            }

            document.getElementById("tab-" + tabName).classList.add("active");
            
            if(tabName === 'desc') btns[0].classList.add("active");
            else btns[1].classList.add("active");

            // 지도 탭 열 때 레이아웃 재설정
            if (tabName === 'map' && map) {
                setTimeout(function() {
                    map.relayout(); 
                    if (mapCenterCoords) {
                        map.setCenter(mapCenterCoords);
                    }
                }, 100);
            }
        }

        // --- 4. 버튼 기능 ---
        function confirmDelete() {
            if (confirm("정말로 이 상품을 삭제하시겠습니까?")) {
                location.href = "product_delete_action.jsp?product_id=<%= productId %>";
            }
        }

        const btnWish = document.getElementById("btnWish");
        if(btnWish) {
            btnWish.addEventListener("click", () => {
                <% if (currentUserId == null) { %> alert("로그인이 필요합니다."); location.href="loginpage.jsp"; return; <% } %>
                fetch("wishlist_toggle_action.jsp?product_id=<%= productId %>").then(r=>r.json()).then(d=>{
                    if(d.status==="added") { alert("찜 목록에 추가!"); btnWish.classList.add("active"); btnWish.innerText="♥ 찜 취소"; }
                    else { alert("찜 삭제 완료!"); btnWish.classList.remove("active"); btnWish.innerText="♡ 찜하기"; }
                });
            });
        }
        const btnTrade = document.getElementById("btnTrade");
        if(btnTrade) {
            btnTrade.addEventListener("click", () => {
                <% if (currentUserId == null) { %> alert("로그인이 필요합니다."); location.href="loginpage.jsp"; return; <% } %>
                if(!confirm("거래를 요청하시겠습니까?")) return;
                fetch("trade_request_action.jsp", { method:"POST", headers:{"Content-Type":"application/x-www-form-urlencoded"}, body:"product_id=<%= productId %>" })
                .then(r=>r.json()).then(d=>{ alert(d.message); location.reload(); });
            });
        }

        // --- 5. 지도 초기화 ---
        window.onload = function() {
            var mapContainer = document.getElementById('map');
            
            if (typeof kakao === 'undefined') {
                mapContainer.innerHTML = "<div style='text-align:center;padding-top:150px;color:#888;'>⚠️ 지도 로드 실패 (AdBlock 확인)</div>";
                return;
            }

            kakao.maps.load(function() {
                var mapOption = { center: new kakao.maps.LatLng(37.566826, 126.9786567), level: 3 };
                map = new kakao.maps.Map(mapContainer, mapOption); 
                
                // 따옴표 제거 및 괄호 제거 (검색 정확도 향상)
                var rawAddr = "<%= (pSellerAddr != null) ? pSellerAddr.replaceAll("\"", "").replaceAll("\'", "").trim() : "" %>";
                var cleanAddr = rawAddr.split('(')[0].trim();

                if (cleanAddr && cleanAddr !== "미등록") {
                    var geocoder = new kakao.maps.services.Geocoder();
                    geocoder.addressSearch(cleanAddr, function(result, status) {
                        if (status === kakao.maps.services.Status.OK) {
                            var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
                            mapCenterCoords = coords; 

                            // ✨ 마커만 표시 (말풍선 제거됨)
                            var marker = new kakao.maps.Marker({ map: map, position: coords });
                            
                            map.setCenter(coords);
                        } else {
                            console.warn("주소 검색 실패: " + cleanAddr);
                        }
                    });
                }
            });
        };
    </script>
</body>
</html>