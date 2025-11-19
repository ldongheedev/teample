<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 1. 로그인 및 권한 확인
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String isAdminStr = (String) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminStr != null && isAdminStr.equals("true"));

    if (userId == null) {
%>
        <script>
            alert("로그인이 필요한 서비스입니다.");
            location.href = "loginpage.jsp";
        </script>
<%
        return;
    }

    // ✨ [추가] 토스트 메시지 확인
    String toastMessage = (String) session.getAttribute("toastMessage");
    if (toastMessage != null) {
        session.removeAttribute("toastMessage"); // 한 번만 보여주기 위해 삭제
    }

    // 2. DB 조회
    List<Map<String, Object>> inquiryList = new ArrayList<>();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "";
        if (isAdmin) {
            sql = "SELECT * FROM Inquiry ORDER BY created_at DESC";
            pstmt = conn.prepareStatement(sql);
        } else {
            sql = "SELECT * FROM Inquiry WHERE user_id = ? ORDER BY created_at DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
        }
        
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", rs.getInt("inquiry_id"));
            item.put("category", rs.getString("category"));
            item.put("title", rs.getString("title"));
            item.put("content", rs.getString("content"));
            item.put("answer", rs.getString("answer")); 
            item.put("status", rs.getString("status")); 
            item.put("date", sdf.format(rs.getTimestamp("created_at")));
            item.put("writer", rs.getString("user_id"));
            inquiryList.add(item);
        }

    } catch (Exception e) {
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
    <title>1:1 문의 - 중고모아</title>
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

        /* --- [고정] 상단 헤더 --- */
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

        /* --- 1:1 문의 스타일 --- */
        .inquiry-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 30px;
            background-color: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 8px;
            min-height: 600px;
        }
        .inquiry-container h2 { font-size: 28px; font-weight: 700; text-align: center; margin-bottom: 40px; color: #333; }
        
        .inquiry-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .inquiry-table th, .inquiry-table td { padding: 15px; text-align: center; border-bottom: 1px solid #eee; font-size: 15px; }
        .inquiry-table th { background-color: #f8f9fa; font-weight: 600; color: #555; border-top: 2px solid #333; }
        
        .inquiry-row { cursor: pointer; transition: background-color 0.2s; }
        .inquiry-row:hover { background-color: #f0f8ff; } 
        
        .inquiry-table td.title { text-align: left; padding-left: 20px; font-weight: 500; }
        
        .detail-row { display: none; background-color: #fafafa; border-bottom: 1px solid #ddd; }
        .detail-content { padding: 30px 40px; text-align: left; }
        
        .q-box { margin-bottom: 20px; }
        .q-mark { color: #ff9800; font-weight: bold; font-size: 18px; margin-right: 8px; }
        .q-text { white-space: pre-wrap; line-height: 1.6; color: #333; }
        
        .a-box { margin-top: 20px; padding: 20px; background-color: #fff; border: 1px solid #eee; border-radius: 8px; }
        .a-mark { color: #4caf50; font-weight: bold; font-size: 18px; margin-right: 8px; }
        .a-text { white-space: pre-wrap; line-height: 1.6; color: #333; }
        
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
        .status-waiting { background-color: #f0f0f0; color: #888; border: 1px solid #ddd; }
        .status-answered { background-color: #e8f5e9; color: #4caf50; border: 1px solid #c8e6c9; }

        .write-btn-area { text-align: right; margin-top: 20px; }
        .btn-write { display: inline-block; padding: 12px 25px; background-color: #333; color: white; text-decoration: none; border-radius: 4px; font-weight: 500; }
        
        /* 관리자 답변 폼 스타일 */
        .admin-form textarea { width: 100%; height: 120px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; resize: vertical; font-family: inherit; margin-top: 10px; box-sizing: border-box; }
        .admin-form button { margin-top: 10px; padding: 8px 20px; background-color: #2c7be5; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .admin-form button:hover { background-color: #1a68d1; }

        /* --- [추가] 토스트 메시지 CSS --- */
        #toast-container { position: fixed; bottom: 30px; right: 30px; z-index: 9999; }
        .toast { 
            background-color: #333; color: white; padding: 15px 25px; border-radius: 8px; 
            margin-bottom: 10px; opacity: 0; transform: translateY(20px); transition: opacity 0.4s, transform 0.4s; 
            box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 15px; 
        }
        .toast.show { opacity: 1; transform: translateY(0); }

        /* --- [고정] 하단 푸터 --- */
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
        
        function toggleDetail(id) {
            var row = document.getElementById('detail-' + id);
            if (row.style.display === 'table-row') {
                row.style.display = 'none';
            } else {
                var allRows = document.getElementsByClassName('detail-row');
                for(var i=0; i<allRows.length; i++) {
                    allRows[i].style.display = 'none';
                }
                row.style.display = 'table-row';
            }
        }

        // ✨ [추가] 토스트 메시지 표시 스크립트
        const jspToastMessage = "<%= (toastMessage != null) ? toastMessage : "" %>";
        window.onload = function() {
            if (jspToastMessage) {
                showToast(jspToastMessage);
            }
        };

        function showToast(message) {
            const container = document.getElementById('toast-container');
            if (!container) return;

            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.textContent = message;
            container.appendChild(toast);
            
            // 애니메이션 효과
            setTimeout(() => { toast.classList.add('show'); }, 10);
            
            // 3초 뒤 제거
            setTimeout(() => { 
                toast.classList.remove('show'); 
                setTimeout(() => { 
                    if (container.contains(toast)) container.removeChild(toast); 
                }, 400);
            }, 3000);
        }
    </script>
</head>
<body>
    <div id="toast-container"></div>

    <header>
        <div class="logo"><a href="main_page.jsp"><img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;"></a></div>
        <div class="header-links">
            <div class="welcome-message"><%= userName %>님, 환영합니다.</div>
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

    <div class="inquiry-container">
        <h2>1:1 문의</h2>
        
        <table class="inquiry-table">
            <colgroup>
                <col style="width: 8%;">
                <col style="width: 12%;">
                <col style="width: 15%;">
                <col style="width: auto;">
                <col style="width: 15%;">
                <% if (isAdmin) { %> <col style="width: 10%;"> <% } %>
            </colgroup>
            <thead>
                <tr>
                    <th>번호</th>
                    <th>상태</th>
                    <th>카테고리</th>
                    <th>제목</th>
                    <th>등록일</th>
                    <% if (isAdmin) { %> <th>작성자</th> <% } %>
                </tr>
            </thead>
            <tbody>
                <% if (inquiryList.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= isAdmin ? 6 : 5 %>" class="no-data" style="padding: 50px;">등록된 문의가 없습니다.</td>
                    </tr>
                <% } else { 
                    int idx = inquiryList.size();
                    for (Map<String, Object> item : inquiryList) {
                        String status = (String) item.get("status");
                        String answer = (String) item.get("answer");
                        String content = (String) item.get("content");
                        
                        String statusClass = "status-waiting";
                        String statusText = "답변대기";
                        if ("ANSWERED".equals(status)) {
                            statusClass = "status-answered";
                            statusText = "답변완료";
                        }
                %>
                    <tr class="inquiry-row" onclick="toggleDetail(<%= item.get("id") %>)">
                        <td><%= idx-- %></td>
                        <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                        <td><%= item.get("category") %></td>
                        <td class="title"><%= item.get("title") %></td>
                        <td><%= item.get("date") %></td>
                        <% if (isAdmin) { %>
                            <td style="color:#888; font-size:13px;"><%= item.get("writer") %></td>
                        <% } %>
                    </tr>
                    
                    <tr id="detail-<%= item.get("id") %>" class="detail-row">
                        <td colspan="<%= isAdmin ? 6 : 5 %>">
                            <div class="detail-content">
                                <div class="q-box">
                                    <span class="q-mark">Q.</span>
                                    <span class="q-text"><%= content.replace("\n", "<br>") %></span>
                                </div>
                                
                                <% if (isAdmin) { %>
                                    <div class="a-box admin-form" style="background-color: #f1f8ff; border: 1px solid #cce5ff;">
                                        <span class="a-mark">A.</span> <b>관리자 답변 작성</b>
                                        <form action="inquiry_answer_action.jsp" method="post">
                                            <input type="hidden" name="inquiry_id" value="<%= item.get("id") %>">
                                            <textarea name="answer" placeholder="답변 내용을 입력하세요."><%= (answer != null) ? answer : "" %></textarea>
                                            <div style="text-align:right;">
                                                <button type="submit"><%= (answer != null) ? "답변 수정" : "답변 등록" %></button>
                                            </div>
                                        </form>
                                    </div>
                                <% } else { %>
                                    <% if ("ANSWERED".equals(status) && answer != null) { %>
                                        <div class="a-box">
                                            <span class="a-mark">A.</span>
                                            <span style="font-weight:bold; color:#333;">중고모아 고객센터</span><br><br>
                                            <span class="a-text"><%= answer.replace("\n", "<br>") %></span>
                                        </div>
                                    <% } else { %>
                                        <div class="a-box" style="background-color:#f9f9f9; color:#999; text-align:center;">
                                            아직 답변이 등록되지 않았습니다. <br> 조금만 기다려주세요.
                                        </div>
                                    <% } %>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% 
                    } 
                } 
                %>
            </tbody>
        </table>
        
        <div class="write-btn-area">
            <a href="inquiry_write_form.jsp" class="btn-write">문의하기</a>
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
                <% if (isAdmin) { %> <br><a href="admin_page.jsp" class="admin-link">관리자 페이지</a> <% } %>
            </div>
        </div>
    </footer>

</body>
</html>