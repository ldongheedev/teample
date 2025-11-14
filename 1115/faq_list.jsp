<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // 1. 관리자 여부 확인 (버튼 표시용)
    String isAdmin = (String) session.getAttribute("isAdmin");
    boolean isManager = (isAdmin != null && isAdmin.equals("true"));

    // 2. 카테고리 파라미터 받기
    String category = request.getParameter("category");
    if (category == null || category.isEmpty()) {
        category = "주문";
    }

    // 3. DB에서 FAQ 목록 조회
    ArrayList<Map<String, String>> faqList = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String toastMessage = (String) session.getAttribute("toastMessage");
    if (toastMessage != null) {
        session.removeAttribute("toastMessage");
    }

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "SELECT faq_id, category, question, answer FROM Faq WHERE category = ? ORDER BY faq_id DESC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, category);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            HashMap<String, String> item = new HashMap<>();
            item.put("faq_id", rs.getString("faq_id"));
            item.put("category", rs.getString("category"));
            item.put("question", rs.getString("question"));
            item.put("answer", rs.getString("answer")); 
            faqList.add(item);
        }
        
    } catch(Exception e) {
        e.printStackTrace(); 
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
    <title>고객센터 - FAQ</title>
    
    <style>
        /* [공통] 웹폰트 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            color: #333;
        }

        /* --- 1. [고정] 상단 헤더 CSS --- */
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
        .header-links a {
            margin-left: 20px;
            text-decoration: none;
            color: #555;
            font-size: 14px;
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
        /* --- [고정] 상단 헤더 CSS 끝 --- */


        /* --- 2. [고정] 하단 푸터 CSS --- */
        footer {
            background-color: #f1f1f1;
            padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
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
        .admin-link:hover {
            text-decoration: underline;
        }
        /* --- [고정] 하단 푸터 CSS 끝 --- */
        

        /* --- 3. [페이지 전용] FAQ 콘텐츠 CSS --- */
        .faq-container {
            width: 1000px;
            margin: 40px auto;
            background-color: #ffffff;
            padding: 30px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        .faq-container h2 {
            font-size: 28px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
        }
        .tab-menu {
            display: flex;
            gap: 10px;
            border-bottom: 1px solid #ddd;
            margin-bottom: 30px;
        }
        .tab-menu a {
            padding: 12px 20px;
            text-decoration: none;
            color: #555;
            font-weight: 500;
            border-bottom: 3px solid transparent;
            transition: all 0.2s;
        }
        .tab-menu a.active {
            color: #2c7be5;
            font-weight: 700;
            border-bottom-color: #2c7be5;
        }
        .tab-menu a:hover {
            color: #2c7be5;
            background-color: #f4f7fa;
        }
        .accordion-item {
            border-bottom: 1px solid #eee;
        }
        .accordion-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .accordion-header:hover {
            background-color: #f9f9f9;
        }
        .accordion-header .q-icon {
            color: #2c7be5;
            font-weight: 700;
            font-size: 18px;
            margin-right: 15px;
        }
        .accordion-header .question-title {
            flex-grow: 1;
            font-size: 16px;
            font-weight: 500;
        }
        .admin-controls {
            display: flex;
            gap: 8px;
            margin-left: 15px;
        }
        .admin-controls .btn-edit,
        .admin-controls .btn-delete {
            text-decoration: none;
            padding: 4px 8px;
            font-size: 12px;
            border-radius: 4px;
            color: white;
            transition: opacity 0.2s;
        }
        .admin-controls .btn-edit { background-color: #5cb85c; }
        .admin-controls .btn-delete { background-color: #d9534f; }
        .admin-controls .btn-edit:hover,
        .admin-controls .btn-delete:hover { opacity: 0.8; }
        .accordion-content {
            display: none;
            padding: 20px;
            background-color: #fdfdfd;
            border-top: 1px dashed #ddd;
        }
        .accordion-content .a-icon {
            color: #d9534f;
            font-weight: 700;
            font-size: 18px;
            margin-right: 15px;
        }
        .accordion-content .answer-text {
            padding-left: 33px;
            line-height: 1.7;
            white-space: pre-wrap;
        }
        .no-data {
            text-align: center;
            padding: 50px;
            color: #888;
            font-size: 16px;
        }
        .write-button-area {
            text-align: right;
            margin-top: 20px;
        }
        .btn-write {
            display: inline-block;
            padding: 10px 20px;
            background-color: #337ab7;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 500;
            transition: background-color 0.2s;
        }
        .btn-write:hover {
            background-color: #286090;
        }
        /* --- [페이지 전용] FAQ 콘텐츠 CSS 끝 --- */


        /* --- [공통] 토스트 메시지 CSS --- */
        #toast-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 9999;
        }
        .toast {
            background-color: #333;
            color: white;
            padding: 12px 20px;
            border-radius: 5px;
            margin-bottom: 10px;
            opacity: 0;
            transition: opacity 0.5s, transform 0.5s;
            transform: translateY(100%);
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            font-size: 14px;
        }
        .toast.show {
            opacity: 1;
            transform: translateY(0);
        }
        .toast.error { background-color: #d9534f; }
        .toast.success { background-color: #5cb85c; }
    </style>
</head>
<body>

    <div id="toast-container"></div>

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
                
                <input type="button" value="" onclick="location.href='loginpage.jsp'"
                    style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
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
                    background-size: contain;
                    width: 40px; height: 40px; border: none; cursor: pointer;"
                />
                
            <%
            }
            %>
        </div>
    </header>

    <div class="faq-container">
        <h2>고객센터 FAQ</h2>

        <div class="tab-menu">
            <a href="faq_list.jsp?category=주문" class="<%= "주문".equals(category) ? "active" : "" %>">주문/결제</a>
            <a href="faq_list.jsp?category=회원정보" class="<%= "회원정보".equals(category) ? "active" : "" %>">회원정보</a>
            <a href="faq_list.jsp?category=기타" class="<%= "기타".equals(category) ? "active" : "" %>">기타</a>
        </div>

        <div class="accordion-list">
            <% if (faqList.isEmpty()) { %>
                <div class="no-data">등록된 FAQ가 없습니다.</div>
            <% } else { %>
                <% for (Map<String, String> item : faqList) { %>
                    <div class="accordion-item">
                        <div class="accordion-header">
                            <span class="q-icon">Q</span>
                            <span class="question-title"><%= item.get("question") %></span>
                            
                            <% if (isManager) { %>
                                <div class="admin-controls">
                                    <a href="faq_update_form.jsp?faq_id=<%= item.get("faq_id") %>" class="btn-edit">수정</a>
                                    <a href="#" onclick="confirmDelete(<%= item.get("faq_id") %>)" class="btn-delete">삭제</a>
                                </div>
                            <% } %>
                        </div>
                        <div class="accordion-content">
                            <span class="a-icon">A</span>
                            <div class="answer-text">
                                <%= item.get("answer").replace("\n", "<br>") %>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
        
        <% if (isManager) { %>
            <div class="write-button-area">
                <a href="faq_add_form.jsp" class="btn-write">새 FAQ 작성</a>
            </div>
        <% } %>
        
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
                <a href="#"> <%= question %> </a><br>
                <a href="faq_list.jsp"> <%= faq %> </a>
                
                <%
                    // (상단에서 이미 선언한 'isAdmin' 변수 사용)
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
        // --- [공통] 토스트 메시지 스크립트 ---
        const jspToastMessage = "<%= (toastMessage != null) ? toastMessage : "" %>";

        window.onload = function() {
            if (jspToastMessage) {
                const type = jspToastMessage.includes("오류") || jspToastMessage.includes("실패") ? 'error' : 'success';
                showToast(jspToastMessage, type, 3000);
            }
        };

        function showToast(message, type = 'success', duration = 3000) {
            const container = document.getElementById('toast-container');
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
                    if (container.contains(toast)) {
                        container.removeChild(toast);
                    }
                }, 500);
            }, duration);
        }

        // --- [공통] 헤더 드롭다운 스크립트 ---
        function toggleDropdown() {
            document.getElementById("myDropdown").classList.toggle("show");
        }
        
        window.onclick = function(event) {
          // 드롭다운 이미지(.dropdown-toggle)를 클릭한 경우는 제외
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
        
        // --- [페이지 전용] FAQ 스크립트 ---
        document.querySelectorAll('.accordion-header').forEach(header => {
            header.addEventListener('click', event => {
                if (event.target.closest('.admin-controls')) {
                    return;
                }
                
                const content = header.nextElementSibling;
                
                if (content.style.display === "block") {
                    content.style.display = "none";
                } else {
                    content.style.display = "block";
                }
            });
        });

        function confirmDelete(faqId) {
            if (confirm("정말로 이 FAQ를 삭제하시겠습니까?")) {
                location.href = "faq_delete_action.jsp?faq_id=" + faqId + "&category=<%= category %>";
            }
        }
    </script>

</body>
</html>