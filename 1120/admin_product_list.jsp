<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // 1. 관리자 권한 확인
    String isAdmin = (String) session.getAttribute("isAdmin");
    String userName = (String) session.getAttribute("userName");
    
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

    // 2. 검색 파라미터 받기
    String searchCategory = request.getParameter("category_id"); // 카테고리 ID
    String searchKeyword = request.getParameter("keyword");      // 검색어

    if (searchCategory == null) searchCategory = "";
    if (searchKeyword == null) searchKeyword = "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 전체 상품 관리</title>
    
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
        
        /* ✨ 검색 영역 스타일 */
        .search-area {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 8px;
            align-items: center;
        }
        .search-area select, .search-area input {
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            height: 40px;
            box-sizing: border-box;
        }
        .search-area input { flex-grow: 1; }
        .search-btn {
            background-color: #2c7be5; color: white; border: none; padding: 0 20px; height: 40px; border-radius: 4px; cursor: pointer; font-weight: bold;
        }
        .search-btn:hover { background-color: #1a68d1; }

        /* 삭제 버튼 */
        .delete-btn { background-color: #d9534f; color: white; border: none; padding: 10px 20px; font-size: 15px; font-weight: 500; border-radius: 5px; cursor: pointer; }
        .delete-btn:hover { background-color: #c9302c; }

        /* 상품 그리드 스타일 */
        .product-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .product-card { background-color: #fff; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); padding: 15px; position: relative; }
        .product-card-checkbox { position: absolute; top: 10px; right: 10px; transform: scale(1.3); z-index: 10; cursor: pointer; }
        .product-card img { width: 100%; height: 200px; object-fit: contain; background-color: #ffffff; border-radius: 4px; margin-bottom: 10px; }
        .product-card .info { padding: 0; }
        .product-card .info .name { font-size: 16px; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin: 5px 0; }
        .product-card .info .price { font-size: 15px; font-weight: bold; color: #333; margin-top: 5px; }
        .product-card .info .seller { font-size: 13px; color: #888; margin-top: 5px; border-top: 1px dashed #eee; padding-top: 5px; }

        /* [고정] 하단 푸터 CSS */
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; margin-top: 40px; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }
        .admin-link { font-weight: bold; color: #2c7be5; margin-top: 10px; display: inline-block; }
        .admin-link:hover { text-decoration: underline; }
        
        /* 토스트 메시지 */
        #toast-container { position: fixed; bottom: 30px; right: 30px; z-index: 9999; }
        .toast { background-color: #333; color: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 10px; opacity: 0; transform: translateY(20px); transition: opacity 0.4s, transform 0.4s; box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 15px; }
        .toast.show { opacity: 1; transform: translateY(0); }
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
        
        function confirmDelete() {
            const checkedCount = document.querySelectorAll('input[name="product_id"]:checked').length;
            if (checkedCount === 0) {
                alert("삭제할 상품을 1개 이상 선택하세요.");
                return false;
            }
            return confirm("선택한 " + checkedCount + "개의 상품을 정말 삭제하시겠습니까?\n(관리자 권한으로 모든 데이터가 영구 삭제됩니다)");
        }

        const jspToastMessage = "<%= session.getAttribute("toastMessage") != null ? session.getAttribute("toastMessage") : "" %>";
        <% session.removeAttribute("toastMessage"); %> 
        
        window.onload = function() {
            if (jspToastMessage) showToast(jspToastMessage);
        };

        function showToast(message) {
            const container = document.getElementById('toast-container');
            if (!container) return;
            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => { toast.classList.add('show'); }, 10);
            setTimeout(() => { 
                toast.classList.remove('show'); 
                setTimeout(() => { if (container.contains(toast)) container.removeChild(toast); }, 400);
            }, 3000);
        }
    </script>
</head>
<body>
    <div id="toast-container"></div>

    <header>
        <div class="logo"><a href="main_page.jsp"><img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;"></a></div>
        <div class="header-links">
            <div class="welcome-message">관리자 <%= userName %>님, 환영합니다.</div>
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
                <li><a href="#">회원 목록</a></li> 
                <li><a href="#">회원 정지/탈퇴</a></li> 
            </ul>
            
            <h3>상품 관리</h3>
            <ul>
                <li class="active"><a href="admin_product_list.jsp">전체 상품 목록</a></li> 
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
                <h2>전체 상품 목록</h2>
                </div>

            <form action="admin_product_list.jsp" method="get" class="search-area">
                <select name="category_id">
                    <option value="">전체 카테고리</option>
                    <%
                        // DB에서 카테고리 목록 불러오기
                        Connection connCat = null;
                        PreparedStatement pstmtCat = null;
                        ResultSet rsCat = null;
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            connCat = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                            String sqlCat = "SELECT category_id, category_name FROM category ORDER BY sort_order";
                            pstmtCat = connCat.prepareStatement(sqlCat);
                            rsCat = pstmtCat.executeQuery();
                            while (rsCat.next()) {
                                String cId = rsCat.getString("category_id");
                                String cName = rsCat.getString("category_name");
                                String selected = cId.equals(searchCategory) ? "selected" : "";
                    %>
                                <option value="<%= cId %>" <%= selected %>><%= cName %></option>
                    <%
                            }
                        } catch(Exception e) { e.printStackTrace(); }
                        finally {
                             if (rsCat != null) try { rsCat.close(); } catch(SQLException ex) {}
                             if (pstmtCat != null) try { pstmtCat.close(); } catch(SQLException ex) {}
                             if (connCat != null) try { connCat.close(); } catch(SQLException ex) {}
                        }
                    %>
                </select>
                <input type="text" name="keyword" placeholder="상품명 또는 판매자명 검색" value="<%= searchKeyword %>">
                <button type="submit" class="search-btn">검색</button>
            </form>
            
            <form action="admin_product_delete_action.jsp" method="post" onsubmit="return confirmDelete();">
                <div style="text-align: right; margin-bottom: 15px;">
                    <button type="submit" class="delete-btn">선택 상품 삭제 (관리자)</button> 
                </div>

                <div class="product-grid">
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        boolean hasProducts = false;
                        DecimalFormat formatter = new DecimalFormat("#,###");
                        
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                            
                            // ✨ 동적 쿼리 작성 (검색 조건 반영)
                            String sql = "SELECT p.product_id, p.product_name, p.price, p.main_image_url, m.nickname " + 
                                         "FROM Product p " + 
                                         "JOIN member m ON p.user_id = m.id " +
                                         "WHERE 1=1 "; // 기본 조건
                            
                            if (!searchCategory.isEmpty()) {
                                sql += "AND p.category_id = ? ";
                            }
                            if (!searchKeyword.isEmpty()) {
                                sql += "AND (p.product_name LIKE ? OR m.nickname LIKE ?) ";
                            }
                            sql += "ORDER BY p.created_at DESC";

                            pstmt = conn.prepareStatement(sql);
                            
                            int paramIndex = 1;
                            if (!searchCategory.isEmpty()) {
                                pstmt.setString(paramIndex++, searchCategory);
                            }
                            if (!searchKeyword.isEmpty()) {
                                pstmt.setString(paramIndex++, "%" + searchKeyword + "%");
                                pstmt.setString(paramIndex++, "%" + searchKeyword + "%");
                            }

                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                hasProducts = true;
                                int pId = rs.getInt("product_id");
                                String pName = rs.getString("product_name");
                                int pPrice = rs.getInt("price");
                                String pImage = rs.getString("main_image_url");
                                String pSeller = rs.getString("nickname");
                                
                                if (pImage == null || pImage.trim().isEmpty()) {
                                    pImage = request.getContextPath() + "/images/logo.png";
                                } else {
                                    pImage = request.getContextPath() + pImage;
                                }
                    %>
                            <div class="product-card">
                                <input type="checkbox" name="product_id" value="<%= pId %>" class="product-card-checkbox">
                                <a href="product_detail.jsp?product_id=<%= pId %>" target="_blank">
                                    <img src="<%= pImage %>" alt="<%= pName %>">
                                </a>
                                <div class="info">
                                    <p class="name"><%= pName %></p>
                                    <p class="price"><%= formatter.format(pPrice) %>원</p>
                                    <p class="seller">판매자: <b><%= pSeller %></b></p> 
                                </div>
                            </div>
                    <%
                            }
                            
                            if (!hasProducts) {
                                out.println("<p style='grid-column: 1/-1; text-align:center; padding:50px; color:#888;'>조건에 맞는 상품이 없습니다.</p>");
                            }

                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<p style='color:red;'>오류 발생: " + e.getMessage() + "</p>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
                            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                        }
                    %>
                </div>
            </form>
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