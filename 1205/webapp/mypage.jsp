<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="util.DBManager" %>

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
    
    DecimalFormat formatter = new DecimalFormat("#,###");

    // 2. 최근 본 상품 쿠키 처리
    String recentCookieName = "recent_products_" + userId;
    String recentProps = "";
    Cookie[] cookies = request.getCookies();
    List<String> recentIds = new ArrayList<>();
    if (cookies != null) {
        for (Cookie c : cookies) {
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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 중고모아</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

        .mypage-wrapper { display: flex; max-width: 1400px; min-height: 70vh; margin: 20px auto; gap: 20px; }
        .mypage-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; height: fit-content; }
        .mypage-sidebar h3 { font-size: 18px; color: #333; margin-top: 0; margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .mypage-sidebar ul { list-style: none; padding: 0; margin: 0 0 20px 0; }
        .mypage-sidebar li a { display: block; padding: 12px 15px; text-decoration: none; color: #555; font-size: 15px; border-radius: 6px; }
        .mypage-sidebar li a:hover { background-color: #f5f5f5; }
        .mypage-sidebar li.active a { background-color: #81c147; color: white; font-weight: 500; }
        
        .mypage-content { flex-grow: 1; background-color: #ffffff; padding: 30px 40px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; }
        .mypage-content h2 { font-size: 24px; margin-top: 0; margin-bottom: 25px; border-bottom: 2px solid #333; padding-bottom: 10px; }
        
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; margin-top: 30px; }
        .section-header h3 { font-size: 18px; font-weight: 700; color: #555; margin: 0; }
        .section-header:first-of-type { margin-top: 0; }

        /* ✨ [수정됨] 3개 기준으로 높이 조절 */
        .product-list-container { 
            display: flex; 
            flex-direction: column; 
            gap: 15px; 
            width: 100%;
            
            /* 핵심: 높이 제한 (3개 정도 보일 높이) */
            max-height: 430px; 
            overflow-y: auto;  
            padding-right: 10px;
        }

        /* 스크롤바 디자인 */
        .product-list-container::-webkit-scrollbar { width: 8px; }
        .product-list-container::-webkit-scrollbar-thumb { background-color: #ccc; border-radius: 4px; }
        .product-list-container::-webkit-scrollbar-track { background-color: #f1f1f1; border-radius: 4px; }
        
        .product-item-row { 
            display: flex; 
            align-items: center; 
            width: 100%; 
            background: white; 
            border: 1px solid #eee; 
            border-radius: 8px; 
            padding: 15px; 
            box-sizing: border-box; 
            transition: 0.2s;
        }
        .product-item-row:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); transform: translateY(-2px); border-color: #ddd; }

        .p-img-row { 
            width: 100px; 
            height: 100px; 
            flex-shrink: 0; 
            border-radius: 6px; 
            overflow: hidden; 
            background-color: #f9f9f9; 
            border: 1px solid #eee;
            margin-right: 20px;
        }
        .p-img-row img { width: 100%; height: 100%; object-fit: cover; }

        .p-info-row { flex-grow: 1; min-width: 0; }
        .p-title-row { 
            font-size: 18px; 
            font-weight: bold; 
            color: #333; 
            text-decoration: none; 
            display: block; 
            margin-bottom: 8px;
            white-space: nowrap; 
            overflow: hidden; 
            text-overflow: ellipsis; 
        }
        .p-title-row:hover { text-decoration: underline; }
        .p-price-row { font-size: 16px; font-weight: 700; color: #2c7be5; }

        .p-actions-row { 
            margin-left: 20px; 
            display: flex; 
            gap: 10px; 
            flex-shrink: 0; 
        }
        .btn-action { 
            padding: 8px 15px; 
            border-radius: 5px; 
            font-size: 13px; 
            font-weight: bold; 
            text-decoration: none; 
            border: 1px solid #ddd;
            transition: 0.2s;
        }
        .btn-edit { background-color: #fff; color: #555; }
        .btn-edit:hover { background-color: #f5f5f5; border-color: #ccc; }
        
        .btn-delete { background-color: #fff; color: #e03131; border-color: #ffc9c9; }
        .btn-delete:hover { background-color: #ffe3e3; border-color: #ff8787; }

        /* 최근 본 상품 */
        .recent-list-wrapper { display: flex; gap: 15px; overflow-x: auto; padding-bottom: 10px; }
        .recent-item { min-width: 140px; width: 140px; border: 1px solid #eee; border-radius: 8px; overflow: hidden; background: white; }
        .recent-item .p-img { height: 120px; width: 100%; }
        .recent-item .p-img img { width: 100%; height: 100%; object-fit: cover; }
        .recent-item .p-info { padding: 10px; }
        .recent-item .p-title { font-size: 13px; font-weight: 500; margin-bottom: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .recent-item .p-price { font-size: 14px; font-weight: 700; color: #2c7be5; }

        .empty-msg { width: 100%; text-align: center; padding: 40px; color: #999; font-size: 14px; background-color: #fcfcfc; border-radius: 8px; border: 1px dashed #ddd; }
    </style>
</head>
<body>

    <jsp:include page="header.jsp" />

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
                <li><a href="trade?cmd=list">거래조회</a></li>
            </ul>
            <h3>상품관리</h3>
            <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
            <h3>고객센터</h3>
            <ul>
                <li><a href="customer?cmd=inquiryList">1:1 문의</a></li>
                <li><a href="faq_list.jsp">FAQ</a></li>
            </ul>
        </nav>

        <div class="mypage-content">
            <h2>내 상점 관리</h2>
            
            <div class="section-header">
                <h3>등록한 상품 목록</h3>
                <a href="product_add_form.jsp" style="font-size: 13px; color: #2c7be5; font-weight: bold; text-decoration: none;">+ 상품 등록 바로가기</a>
            </div>
            
            <div class="product-list-container">
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DBManager.getConnection();
                    
                    String sql = "SELECT * FROM Product WHERE user_id = ? ORDER BY created_at DESC";
                    
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
                    <div class="product-item-row">
                        <div class="p-img-row">
                            <a href="product_detail.jsp?product_id=<%= pId %>">
                                <img src="<%= request.getContextPath() + pImg %>" alt="<%= pName %>">
                            </a>
                        </div>
                        
                        <div class="p-info-row">
                            <a href="product_detail.jsp?product_id=<%= pId %>" class="p-title-row"><%= pName %></a>
                            <div class="p-price-row"><%= formatter.format(pPrice) %>원</div>
                        </div>

                        <div class="p-actions-row">
                            <a href="product_edit.jsp?product_id=<%= pId %>" class="btn-action btn-edit">수정</a>
                            <a href="product?cmd=delete&product_id=<%= pId %>" onclick="return confirm('정말 삭제하시겠습니까?')" class="btn-action btn-delete">삭제</a>
                        </div>
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
                    DBManager.close(conn, pstmt, rs);
                }
                %>
            </div>

            <div class="section-header">
                <h3>최근 본 상품 <span style="font-size: 12px; color: #888;">(최대 5개)</span></h3>
            </div>
            
            <div class="recent-list-wrapper">
                <%
                if (recentIds.isEmpty()) {
                %>
                    <div class="empty-msg" style="grid-column: auto; width: 100%;">최근 본 상품 내역이 없습니다.</div>
                <%
                } else {
                    try {
                        conn = DBManager.getConnection();
                        
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
                        DBManager.close(conn, pstmt, rs);
                    }
                }
                %>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />

    <script>
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