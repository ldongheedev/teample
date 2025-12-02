<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedList" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="util.DBManager" %>

<%
    String currentUserId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    
    String productIdStr = request.getParameter("product_id");
    if (productIdStr == null) { out.println("<script>alert('상품 ID가 없습니다.'); history.back();</script>"); return; }
    int productId = Integer.parseInt(productIdStr);

    // 쿠키 로직
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
        for (String s : ids) { if (!s.isEmpty()) recentList.add(s); }
    }
    String currentIdStr = String.valueOf(productId);
    recentList.remove(currentIdStr);
    recentList.addFirst(currentIdStr);
    if (recentList.size() > 5) recentList.removeLast();
    Cookie newCookie = new Cookie(recentCookieName, URLEncoder.encode(String.join("/", recentList), "UTF-8"));
    newCookie.setMaxAge(60 * 60 * 24);
    newCookie.setPath("/"); 
    response.addCookie(newCookie);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String pName="", pDesc="", pMainImg="", pCategory="", pSellerNick="", pSellerPhone="";
    String pTradeAddr = ""; 
    int pPrice=0; boolean pIsSoldOut=false;
    String pCreatedAt="";
    boolean isShippingIncluded = false; 
    boolean isDirectTrade = false;
    ArrayList<String> detailImages = new ArrayList<>();
    String pSellerId = null;
    boolean isWished = false; 
    String tradeStatus = null;
    DecimalFormat formatter = new DecimalFormat("#,###");

    try {
        conn = DBManager.getConnection();
        String sql = "SELECT p.*, m.nickname, m.phone, m.trade_addr, c.category_name " +
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
            pTradeAddr = rs.getString("trade_addr"); 
            pIsSoldOut = rs.getBoolean("is_sold_out");
            pCreatedAt = rs.getString("created_at").substring(0, 16);
            
            try { isShippingIncluded = rs.getBoolean("shipping_included"); } catch(Exception e) {}
            try { isDirectTrade = rs.getBoolean("is_direct_trade"); } catch(Exception e) {}
        } else {
            out.println("<script>alert('존재하지 않는 상품입니다.'); history.back();</script>");
            return;
        }
        DBManager.close(null, pstmt, rs);

        String imgSql = "SELECT image_url FROM ProductImage WHERE product_id = ? ORDER BY display_order ASC";
        pstmt = conn.prepareStatement(imgSql);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();
        while (rs.next()) { detailImages.add(rs.getString("image_url")); }
        DBManager.close(null, pstmt, rs);

        if (currentUserId != null) {
            pstmt = conn.prepareStatement("SELECT 1 FROM Wishlist WHERE user_id=? AND product_id=?");
            pstmt.setString(1, currentUserId); pstmt.setInt(2, productId);
            rs = pstmt.executeQuery();
            if (rs.next()) isWished=true;
            DBManager.close(null, pstmt, rs);

            pstmt = conn.prepareStatement("SELECT status FROM TradeRequest WHERE product_id=? AND buyer_id=?");
            pstmt.setInt(1, productId); pstmt.setString(2, currentUserId);
            rs = pstmt.executeQuery();
            if (rs.next()) tradeStatus=rs.getString("status");
            DBManager.close(null, pstmt, rs);
        }

    } catch (Exception e) { e.printStackTrace(); } 
    finally { DBManager.close(conn, pstmt, rs); }
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
        .product-detail-container { max-width: 1000px; margin: 40px auto; display: flex; gap: 40px; }
        .image-section { flex: 1; width: 500px; }
        .swiper-container { width: 100%; height: 450px; border-radius: 10px; overflow: hidden; border: 1px solid #eee; background-color: #f8f9fa; position: relative; }
        .swiper-slide { display: flex; align-items: center; justify-content: center; }
        .swiper-slide img { width: 100%; height: 100%; object-fit: contain; }
        .swiper-button-next, .swiper-button-prev { color: #fff !important; background: rgba(0,0,0,0.3); width: 44px; height: 44px; border-radius: 50%; }
        .swiper-button-next:after, .swiper-button-prev:after { font-size: 20px !important; font-weight: bold; }
        .swiper-pagination-bullet-active { background: #2c7be5 !important; }
        .info-section { flex: 1; display: flex; flex-direction: column; justify-content: flex-start; }
        .category-badge { background-color: #eef1f6; color: #2c7be5; padding: 5px 10px; border-radius: 4px; font-weight: bold; width: fit-content; margin-bottom: 10px; }
        .product-title { font-size: 28px; font-weight: 700; margin-bottom: 10px; }
        .product-price { font-size: 32px; font-weight: 700; color: #2c7be5; margin-bottom: 15px; }
        .trade-options { display: flex; gap: 10px; margin-bottom: 25px; }
        .option-badge { padding: 8px 12px; border-radius: 20px; font-size: 14px; font-weight: bold; display: flex; align-items: center; gap: 5px; }
        .opt-shipping { background-color: #e3f2fd; color: #1565c0; border: 1px solid #90caf9; }
        .opt-direct { background-color: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
        .opt-disabled { background-color: #f5f5f5; color: #aaa; border: 1px solid #ddd; text-decoration: line-through; }
        .product-meta { border-top: 1px solid #eee; border-bottom: 1px solid #eee; padding: 20px 0; margin-bottom: 20px; }
        .meta-row { display: flex; margin-bottom: 10px; font-size: 14px; }
        .meta-label { width: 100px; color: #888; }
        .action-buttons { display: flex; gap: 10px; margin-top: auto; }
        .btn { flex: 1; padding: 15px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; display: flex; justify-content: center; align-items: center; }
        .btn-trade { background-color: #2c7be5; color: white; }
        .btn-trade:disabled { background-color: #ccc; cursor: not-allowed; }
        .btn-wish { background-color: white; border: 1px solid #ddd; }
        .btn-wish.active { border-color: #ff4d4d; color: #ff4d4d; }
        .btn-edit { background-color: #f1f3f5; }
        .btn-delete { background-color: #ffeaea; color: #e03131; }
        .btn-complete { background-color: #37b24d; color: white; }
        .tab-container { max-width: 1000px; margin: 0 auto 60px; }
        .tab-menu { display: flex; border-bottom: 1px solid #eee; }
        .tab-btn { flex: 1; padding: 20px; background: #fcfcfc; border: none; font-size: 16px; font-weight: bold; color: #888; cursor: pointer; }
        .tab-btn.active { background: #fff; color: #2c7be5; border-bottom: 2px solid #2c7be5; }
        .tab-content { display: none; padding: 40px; min-height: 300px; background: white; }
        .tab-content.active { display: block; }
        .desc-content { white-space: pre-wrap; line-height: 1.6; font-size: 16px; }
        .map-title { font-size: 18px; font-weight: 700; margin-bottom: 15px; }
        #map { width: 100%; height: 400px; border-radius: 8px; background-color: #eee; }

        /* ✨ 토스트 메시지 CSS 추가 */
        #toast-container { position: fixed; bottom: 30px; right: 30px; z-index: 9999; }
        .toast { 
            background-color: #333; color: white; padding: 15px 25px; border-radius: 8px; 
            margin-bottom: 10px; opacity: 0; transform: translateY(20px); transition: opacity 0.4s, transform 0.4s;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 15px; display: flex; align-items: center;
        }
        .toast.show { opacity: 1; transform: translateY(0); }
        .toast.success { background-color: #2c7be5; } /* 성공 시 파란색 */
        .toast.error { background-color: #e03131; } /* 실패 시 빨간색 */
    </style>
</head>
<body>
    <div id="toast-container"></div>

    <jsp:include page="header.jsp" />

    <div class="product-detail-container">
        <div class="image-section">
            <div class="swiper-container">
                <div class="swiper-wrapper">
                    <div class="swiper-slide"><img src="<%= request.getContextPath() + pMainImg %>"></div>
                    <% for(String img : detailImages) { %>
                        <div class="swiper-slide"><img src="<%= request.getContextPath() + img %>"></div>
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

            <div class="trade-options">
                <% if (isShippingIncluded) { %>
                    <span class="option-badge opt-shipping">📦 택배비 포함</span>
                <% } else { %>
                    <span class="option-badge opt-disabled">📦 택배비 별도</span>
                <% } %>

                <% if (isDirectTrade) { %>
                    <span class="option-badge opt-direct">🤝 직거래 가능</span>
                <% } else { %>
                    <span class="option-badge opt-disabled">🤝 직거래 불가</span>
                <% } %>
            </div>

            <div class="product-meta">
                <div class="meta-row"><span class="meta-label">판매자</span><span><%= pSellerNick %></span></div>
                <div class="meta-row"><span class="meta-label">등록일</span><span><%= pCreatedAt %></span></div>
                
                <% if (isDirectTrade) { %>
                    <div class="meta-row"><span class="meta-label">거래장소</span><span><%= (pTradeAddr != null && !pTradeAddr.trim().isEmpty()) ? pTradeAddr : "미등록" %></span></div>
                <% } %>
            </div>

            <div class="action-buttons">
                <% if (currentUserId != null && currentUserId.equals(pSellerId)) { %>
                    <button class="btn btn-edit" onclick="location.href='product_edit.jsp?product_id=<%= productId %>'">수정</button>
                    <button class="btn btn-delete" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='product?cmd=delete&product_id=<%= productId %>'">삭제</button>
                    <% if (!pIsSoldOut) { %> <button class="btn btn-complete" onclick="confirmComplete()">거래 완료</button> <% } %>
                <% } else { 
                    boolean isReq = "REQUESTED".equals(tradeStatus) || "ACCEPTED".equals(tradeStatus); %>
                    <button id="btnRequestTrade" class="btn btn-trade" <%= (pIsSoldOut || isReq) ? "disabled" : "" %>>
                        <%= pIsSoldOut ? "판매 완료" : (isReq ? "요청 중" : "거래 요청") %>
                    </button>
                    <button id="btnToggleWish" class="btn btn-wish <%= isWished ? "active" : "" %>"><%= isWished ? "♥ 찜 취소" : "♡ 찜하기" %></button>
                <% } %>
            </div>
        </div>
    </div>

    <div class="tab-container">
        <div class="tab-menu">
            <button class="tab-btn active" onclick="openTab('desc')">상품 상세 설명</button>
            <% if (isDirectTrade) { %>
                <button class="tab-btn" onclick="openTab('map')">거래 희망 장소 (지도)</button>
            <% } %>
        </div>
        <div id="tab-desc" class="tab-content active"><div class="desc-content"><%= pDesc %></div></div>
        
        <% if (isDirectTrade) { %>
            <div id="tab-map" class="tab-content">
                <div class="map-title">📍 거래 희망 장소 <span><%= (pTradeAddr != null) ? pTradeAddr : "미등록" %></span></div>
                <div id="map"></div>
            </div>
        <% } %>
    </div>

    <jsp:include page="footer.jsp" />

    <script>
        // Swiper
        const swiper = new Swiper('.swiper-container', { loop: true, pagination: { clickable: true }, navigation: { nextEl: '.swiper-button-next', prevEl: '.swiper-button-prev' } });

        // Tab & Map
        var map, mapCenterCoords;
        function openTab(n) {
            var t=document.getElementsByClassName("tab-content"), b=document.getElementsByClassName("tab-btn");
            for(var i=0;i<t.length;i++) t[i].classList.remove("active");
            for(var i=0;i<b.length;i++) b[i].classList.remove("active");
            document.getElementById("tab-"+n).classList.add("active");
            
            if(n==='desc') b[0].classList.add("active"); 
            else if (b.length > 1) b[1].classList.add("active");

            if(n==='map' && map) setTimeout(function(){ map.relayout(); if(mapCenterCoords) map.setCenter(mapCenterCoords); }, 100);
        }

        // ✨ 토스트 메시지 함수
        function showToast(message, type = 'default') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.innerText = message;
            container.appendChild(toast);
            
            // 애니메이션
            requestAnimationFrame(() => { toast.classList.add('show'); });
            
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => { toast.remove(); }, 400);
            }, 3000);
        }

        // ✨ 거래 완료 (AJAX -> Toast)
        function confirmComplete() { 
            if(confirm("거래 완료 처리하시겠습니까?")) {
                fetch("trade", {
                    method: "POST", 
                    headers: {"Content-Type":"application/x-www-form-urlencoded"}, 
                    body: "cmd=complete&product_id=<%= productId %>"
                })
                .then(r=>r.json())
                .then(d=>{ 
                    if(d.status==="success"){ 
                        showToast("거래가 완료되었습니다!", "success"); 
                        setTimeout(() => location.reload(), 1500);
                    } else{ 
                        showToast(d.message, "error"); 
                    } 
                }); 
            }
        }

        // ✨ 찜하기 (AJAX -> Toast)
        const btnWish = document.getElementById("btnToggleWish");
        if(btnWish) btnWish.addEventListener("click", function(){ 
            <% if(currentUserId==null){ %>
                showToast("로그인이 필요합니다.", "error"); 
                setTimeout(() => location.href="loginpage.jsp", 1000);
                return;
            <% } %> 
            
            fetch("wishlist_toggle_action.jsp?product_id=<%= productId %>")
            .then(r=>r.json())
            .then(d=>{ 
                if(d.status==="added"){ 
                    showToast("찜 목록에 추가되었습니다.", "success");
                    btnWish.classList.add("active"); 
                    btnWish.innerHTML="♥ 찜 취소";
                } else if(d.status==="removed") {
                    showToast("찜 목록에서 삭제되었습니다.", "default");
                    btnWish.classList.remove("active"); 
                    btnWish.innerHTML="♡ 찜하기";
                } else {
                    showToast(d.message, "error");
                }
            })
            .catch(() => showToast("오류가 발생했습니다.", "error"));
        });

        // ✨ 거래 요청 (AJAX -> Toast + 기능수리)
        const btnTrade = document.getElementById("btnRequestTrade");
        if(btnTrade) btnTrade.addEventListener("click", function(){ 
            <% if(currentUserId==null){ %>
                showToast("로그인이 필요합니다.", "error"); 
                setTimeout(() => location.href="loginpage.jsp", 1000);
                return;
            <% } %> 
            
            if(!confirm("거래 요청하시겠습니까?")) return; 
            
            fetch("trade", {
                method: "POST", 
                headers: {"Content-Type":"application/x-www-form-urlencoded"}, 
                body: "cmd=request&product_id=<%= productId %>"
            })
            .then(r=>r.json())
            .then(d=>{ 
                if(d.status==="success"){ 
                    showToast("거래 요청을 보냈습니다!", "success");
                    setTimeout(() => location.reload(), 1500); 
                } else { 
                    showToast(d.message, "error"); 
                } 
            })
            .catch(err => {
                console.error(err);
                showToast("요청 중 오류가 발생했습니다.", "error");
            });
        });

        <% if (isDirectTrade) { %>
        window.onload = function() {
            var mapContainer = document.getElementById('map');
            if (typeof kakao === 'undefined') { mapContainer.innerHTML = "지도 로드 실패"; return; }
            kakao.maps.load(function() {
                map = new kakao.maps.Map(mapContainer, { center: new kakao.maps.LatLng(37.566826, 126.9786567), level: 3 });
                var addr = "<%= (pTradeAddr != null) ? pTradeAddr.replaceAll("\"", "").trim() : "" %>".split('(')[0].trim();
                if (addr && addr !== "미등록") {
                    new kakao.maps.services.Geocoder().addressSearch(addr, function(result, status) {
                        if (status === kakao.maps.services.Status.OK) {
                            var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
                            mapCenterCoords = coords;
                            new kakao.maps.Marker({ map: map, position: coords });
                            map.setCenter(coords);
                        }
                    });
                }
            });
        };
        <% } %>
    </script>
</body>
</html>