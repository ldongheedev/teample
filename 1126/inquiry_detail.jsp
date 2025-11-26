<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String isAdminStr = (String) session.getAttribute("isAdmin");
    boolean isAdmin = (isAdminStr != null && isAdminStr.equals("true"));

    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }

    String inquiryIdStr = request.getParameter("id");
    if (inquiryIdStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    int inquiryId = Integer.parseInt(inquiryIdStr);

    String category = "", title = "", content = "", answer = "", status = "", regDate = "";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        
        String sql = "SELECT * FROM Inquiry WHERE inquiry_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, inquiryId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // 본인 글이거나 관리자만 볼 수 있음
            String writerId = rs.getString("user_id");
            if (!isAdmin && !writerId.equals(userId)) {
                out.println("<script>alert('권한이 없습니다.'); location.href='inquiry_list.jsp';</script>");
                return;
            }
            
            category = rs.getString("category");
            title = rs.getString("title");
            content = rs.getString("content");
            answer = rs.getString("answer");
            status = rs.getString("status");
            regDate = sdf.format(rs.getTimestamp("created_at"));
        } else {
            out.println("<script>alert('존재하지 않는 문의입니다.'); history.back();</script>");
            return;
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
    <title>문의 상세 - 중고모아</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        
        /* 헤더/푸터 스타일은 list 페이지와 동일 */
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

        /* 상세 페이지 스타일 */
        .detail-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 40px;
            background-color: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        .detail-header {
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .detail-header h2 {
            font-size: 24px;
            margin: 0 0 10px 0;
            color: #333;
        }
        .detail-meta {
            color: #777;
            font-size: 14px;
        }
        .detail-content {
            padding: 20px 0;
            min-height: 150px;
            border-bottom: 1px solid #eee;
            line-height: 1.6;
            white-space: pre-wrap;
        }
        
        .answer-section {
            margin-top: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #eee;
        }
        .answer-title {
            font-weight: 700;
            font-size: 18px;
            color: #2c7be5;
            margin-bottom: 10px;
        }
        .answer-content {
            white-space: pre-wrap;
            line-height: 1.6;
        }

        /* 관리자 답변 폼 */
        .admin-answer-form textarea {
            width: 100%;
            height: 150px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: vertical;
            font-family: 'Noto Sans KR', sans-serif;
            box-sizing: border-box;
        }
        .btn-submit {
            margin-top: 10px;
            padding: 10px 20px;
            background-color: #2c7be5;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }
        .btn-submit:hover { background-color: #1a68d1; }

        .btn-back {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #555;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }

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
    </script>
</head>
<body>
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

    <div class="detail-container">
        <div class="detail-header">
            <h2>[<%= category %>] <%= title %></h2>
            <div class="detail-meta">등록일: <%= regDate %> | 상태: <%= "ANSWERED".equals(status) ? "답변완료" : "답변대기" %></div>
        </div>
        
        <div class="detail-content">
            <%= content %>
        </div>
        
        <% if ("ANSWERED".equals(status)) { %>
            <div class="answer-section">
                <div class="answer-title">관리자 답변</div>
                <div class="answer-content"><%= answer %></div>
            </div>
        <% } else { %>
            <% if (isAdmin) { %>
                <div class="answer-section admin-answer-form">
                    <div class="answer-title">답변 작성</div>
                    <form action="inquiry_answer_action.jsp" method="post">
                        <input type="hidden" name="inquiry_id" value="<%= inquiryId %>">
                        <textarea name="answer" placeholder="답변 내용을 입력하세요." required></textarea>
                        <button type="submit" class="btn-submit">답변 등록</button>
                    </form>
                </div>
            <% } else { %>
                <div class="answer-section" style="text-align:center; color:#888;">
                    아직 답변이 등록되지 않았습니다.
                </div>
            <% } %>
        <% } %>

        <div style="text-align: center;">
            <a href="inquiry_list.jsp" class="btn-back">목록으로</a>
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