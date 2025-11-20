<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    String isAdmin = (String) session.getAttribute("isAdmin");
    String adminName = (String) session.getAttribute("userName");
    
    if (isAdmin == null || !isAdmin.equals("true")) {
%>
        <script>alert("접근 권한이 없습니다."); location.href = "main_page.jsp";</script>
<%
        return;
    }
    
    request.setCharacterEncoding("UTF-8");
    String searchKeyword = request.getParameter("keyword");
    if (searchKeyword == null) searchKeyword = "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 회원 정지/탈퇴 관리</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }

       header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .dropdown-content.show { display: block; }

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

        .search-area { display: flex; gap: 10px; margin-bottom: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px; align-items: center; }
        .search-area input { flex-grow: 1; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; height: 40px; box-sizing: border-box; }
        .search-btn { background-color: #2c7be5; color: white; border: none; padding: 0 20px; height: 40px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .search-btn:hover { background-color: #1a68d1; }

        .manage-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .manage-table th, .manage-table td { padding: 12px 10px; border-bottom: 1px solid #eee; text-align: center; vertical-align: middle; }
        .manage-table th { background-color: #fff0f0; color: #d9534f; font-weight: 600; border-top: 2px solid #d9534f; }
        .manage-table tr:hover { background-color: #fcfcfc; }
        
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .status-active { background-color: #e6fffa; color: #059669; border: 1px solid #a7f3d0; }
        .status-suspended { background-color: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }

        .action-btn { padding: 5px 10px; border-radius: 4px; font-size: 12px; cursor: pointer; border: none; color: white; margin: 0 2px; transition: opacity 0.2s; }
        .action-btn:hover { opacity: 0.8; }
        
        .btn-warn { background-color: #f59e0b; }
        .btn-suspend { background-color: #6b7280; }
        .btn-activate { background-color: #10b981; }
        .btn-delete { background-color: #ef4444; }

        #toast-container { position: fixed; bottom: 30px; right: 30px; z-index: 9999; }
        .toast { background-color: #333; color: white; padding: 15px 25px; border-radius: 8px; margin-bottom: 10px; opacity: 0; transform: translateY(20px); transition: opacity 0.4s, transform 0.4s; box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-size: 15px; }
        .toast.show { opacity: 1; transform: translateY(0); }
        
        footer { background-color: #f1f1f1; padding: 40px; display: flex; justify-content: space-between; font-size: 14px; color: #555; margin-top: 40px; }
        .footer-section h4 { margin-bottom: 10px; font-weight: bold; }
        .footer-section p, .footer-section a { margin: 4px 0; text-decoration: none; color: #555; }
        .admin-link { font-weight: bold; color: #2c7be5; margin-top: 10px; display: inline-block; }
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
        
        function sendWarning(memberId, currentWarnings) {
            let msg = "⚠️ [" + memberId + "] 회원에게 경고를 부여하시겠습니까?\n\n";
            msg += "현재 경고 누적: " + currentWarnings + "회\n";
            msg += "-------------------------\n";
            msg += "❗ 3회: 7일 정지\n";
            msg += "❗ 5회: 30일 정지\n";
            msg += "❗ 10회: 즉시 강제 탈퇴";
            if (confirm(msg)) { location.href = "admin_member_manage_action.jsp?cmd=warn&id=" + memberId; }
        }

        function toggleSuspend(memberId, currentStatus) {
            let msg = currentStatus === 'ACTIVE' ? 
                "[" + memberId + "] 회원을 '무기한 정지' 시키겠습니까?" : 
                "[" + memberId + "] 회원의 정지를 해제하시겠습니까?";
            let cmd = currentStatus === 'ACTIVE' ? "suspend" : "activate";
            if (confirm(msg)) { location.href = "admin_member_manage_action.jsp?cmd=" + cmd + "&id=" + memberId; }
        }

        function forceDelete(memberId) {
            if (confirm("⚠️ [" + memberId + "] 회원을 강제 탈퇴시킵니다.\n이 작업은 복구할 수 없습니다.")) {
                location.href = "admin_member_manage_action.jsp?cmd=delete&id=" + memberId;
            }
        }

        const jspToastMessage = "<%= session.getAttribute("toastMessage") != null ? session.getAttribute("toastMessage") : "" %>";
        <% session.removeAttribute("toastMessage"); %> 
        window.onload = function() { if (jspToastMessage) showToast(jspToastMessage); };

        function showToast(message) {
            const container = document.getElementById('toast-container');
            if (!container) return;
            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.textContent = message;
            container.appendChild(toast);
            setTimeout(() => { toast.classList.add('show'); }, 10);
            setTimeout(() => { toast.classList.remove('show'); setTimeout(() => { if (container.contains(toast)) container.removeChild(toast); }, 400); }, 3000);
        }
    </script>
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
            // 세션에서 정보 가져오기 (페이지마다 중복 선언 방지용 체크)
            String headerUserName = (String) session.getAttribute("userName");
            
            if (headerUserName == null) {
            %>
                <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
                <input type="button" value="" onclick="location.href='loginpage.jsp'" style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center; background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
            <%
            } else {
            %>
                <div class="welcome-message"><%= headerUserName %>님, 환영합니다.</div>
                
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown(event)">
                    
                    <div id="myDropdown" class="dropdown-content">
                        <a href="mypage.jsp">마이페이지</a>
                        <a href="logout.jsp">로그아웃</a>
                    </div>
                </div>
                
                <input type="button" value="" onclick="location.href='notifications.jsp'" style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center; background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;" />
            <%
            }
            %>
        </div>
    </header>

    <script>
        // ✨ [수정] 이벤트 전파 방지 추가
        function toggleDropdown(event) {
            event.stopPropagation(); // 클릭이 윈도우까지 퍼지는 것을 막음 (즉시 닫힘 방지)
            document.getElementById("myDropdown").classList.toggle("show");
        }

        // 화면의 다른 곳을 클릭하면 메뉴 닫기
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

    <div class="admin-wrapper">
        <nav class="admin-sidebar">
            <h3>회원 관리</h3>
            <ul>
                <li><a href="admin_member_list.jsp">회원 목록</a></li> 
                <li class="active"><a href="admin_member_manage.jsp">회원 정지/탈퇴</a></li> 
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
                <h2>회원 정지 및 탈퇴 관리</h2>
            </div>
            
            <form action="admin_member_manage.jsp" method="get" class="search-area">
                <input type="text" name="keyword" placeholder="아이디 또는 닉네임 검색" value="<%= searchKeyword %>">
                <button type="submit" class="search-btn">검색</button>
            </form>

            <table class="manage-table">
                <colgroup>
                    <col style="width: 20%;">
                    <col style="width: 15%;">
                    <col style="width: 15%;">
                    <col style="width: 15%;">
                    <col style="width: 35%;">
                </colgroup>
                <thead>
                    <tr>
                        <th>회원정보</th>
                        <th>닉네임</th>
                        <th>가입일</th>
                        <th>상태 / 경고</th>
                        <th>관리 액션</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat dateFmt = new SimpleDateFormat("yy-MM-dd HH:mm");
                        
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                            
                            // ✨ 에러 방지: 'isAdmin' 체크 없이 모든 회원 조회 후 루프에서 필터링
                            // created_at이 없으면 에러가 나므로 try-catch로 보호하지 않고 직접 조회 (단, 컬럼이 있어야 함)
                            // 여기서는 created_at 대신 가장 안전한 'id'로 정렬하거나, 컬럼이 있다고 가정
                            String sql = "SELECT * FROM member WHERE id LIKE ? OR nickname LIKE ? ORDER BY id DESC";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, "%" + searchKeyword + "%");
                            pstmt.setString(2, "%" + searchKeyword + "%");
                            
                            rs = pstmt.executeQuery();
                            boolean hasMembers = false;

                            while (rs.next()) {
                                String mId = rs.getString("id");
                                
                                // 관리자 계정은 목록에서 제외 (안전하게 자바에서 처리)
                                // isAdmin 컬럼이 없을 수도 있으므로 예외처리
                                try {
                                    String checkAdmin = rs.getString("isAdmin");
                                    if ("true".equals(checkAdmin)) continue;
                                } catch (SQLException e) {
                                    // isAdmin 컬럼이 없으면 그냥 진행 (모두 일반회원으로 간주)
                                }
                                
                                hasMembers = true;
                                String mNick = rs.getString("nickname");
                                
                                String mRegDate = "-";
                                try { 
                                    // created_at이 없으면 reg_date 시도, 둘다 없으면 에러날 수 있음
                                    // 여기서는 안전하게 timestamp 체크
                                    Timestamp ts = null;
                                    try { ts = rs.getTimestamp("created_at"); } catch(SQLException e) {
                                        try { ts = rs.getTimestamp("reg_date"); } catch(SQLException e2) {}
                                    }
                                    if (ts != null) mRegDate = sdf.format(ts);
                                } catch(Exception e){}
                                
                                String mStatus = "ACTIVE";
                                int mWarnings = 0;
                                String mSuspensionEnd = null;
                                
                                try { mStatus = rs.getString("status"); if(mStatus==null) mStatus="ACTIVE"; } catch(SQLException e){}
                                try { mWarnings = rs.getInt("warning_count"); } catch(SQLException e){}
                                try { 
                                    Timestamp tsEnd = rs.getTimestamp("suspension_end_date");
                                    if (tsEnd != null) mSuspensionEnd = dateFmt.format(tsEnd);
                                } catch(SQLException e){}
                                
                                boolean isActive = "ACTIVE".equals(mStatus);
                    %>
                        <tr>
                            <td style="text-align:left; padding-left:20px;">
                                <b><%= mId %></b>
                            </td>
                            <td><%= mNick != null ? mNick : "-" %></td>
                            <td><%= mRegDate %></td>
                            <td>
                                <% if (isActive) { %>
                                    <span class="badge status-active">활동중</span>
                                <% } else { %>
                                    <span class="badge status-suspended">정지됨</span>
                                    <% if (mSuspensionEnd != null) { %>
                                        <br><span style="font-size:11px; color:red;">(~<%= mSuspensionEnd %>)</span>
                                    <% } else { %>
                                        <br><span style="font-size:11px; color:red;">(무기한)</span>
                                    <% } %>
                                <% } %>
                                <br>
                                <span style="font-size:11px; color:#888;">(경고: <%= mWarnings %>회)</span>
                            </td>
                            <td>
                                <button type="button" class="action-btn btn-warn" onclick="sendWarning('<%= mId %>', <%= mWarnings %>)">경고</button>
                                <% if (isActive) { %>
                                    <button type="button" class="action-btn btn-suspend" onclick="toggleSuspend('<%= mId %>', 'ACTIVE')">정지</button>
                                <% } else { %>
                                    <button type="button" class="action-btn btn-activate" onclick="toggleSuspend('<%= mId %>', 'SUSPENDED')">해제</button>
                                <% } %>
                                <button type="button" class="action-btn btn-delete" onclick="forceDelete('<%= mId %>')">강제탈퇴</button>
                            </td>
                        </tr>
                    <%
                            }
                            if (!hasMembers) {
                                out.println("<tr><td colspan='5' style='padding:50px; color:#888;'>검색된 회원이 없습니다.</td></tr>");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            // ✨ 에러 발생 시 화면에 출력
                            out.println("<tr><td colspan='5' style='padding:20px; color:red; font-weight:bold;'>");
                            out.println("DB 조회 오류: " + e.getMessage() + "<br>");
                            out.println("필수 컬럼(status, warning_count 등)이 DB에 있는지 확인해주세요.");
                            out.println("</td></tr>");
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