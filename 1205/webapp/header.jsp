<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // 세션 정보 가져오기
    String headerUserId = (String) session.getAttribute("userId");
    String headerUserName = (String) session.getAttribute("userName");
%>

<style>
    /* 헤더 레이아웃 */
    header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 40px;
        background-color: #ffffff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    
    /* 로고 이미지 */
    .logo img {
        height: 60px;
        width: 200px;
        object-fit: contain;
    }
    
    /* 우측 링크 영역 */
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
    
    /* 링크 스타일 */
    .header-links a {
        margin-left: 20px;
        text-decoration: none; 
        color: #555; 
        font-size: 14px;
    }

    /* 드롭다운 메뉴 (사용자 아이콘) */
    .dropdown {
        position: relative;
        display: inline-block;
    }
    
    /* 사용자 아이콘 크기 고정 */
    .dropdown-toggle {
        height: 40px;
        width: 40px;
        cursor: pointer;
        border-radius: 50%;
        object-fit: cover;
        vertical-align: middle;
    }
    
    /* 드롭다운 내용 */
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
</style>

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
</script>

<header>
    <div class="logo">
        <a href="main_page.jsp">
            <img src="<%= request.getContextPath() %>/images/logo.png" alt="로고">
        </a>
    </div>
    <div class="header-links">
        <% if (headerUserId == null) { %>
            <input type="button" value="로그인/회원가입" onclick="location.href='loginpage.jsp'">
            
            <input type="button" value="" onclick="location.href='loginpage.jsp'"
                style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;"
            />
        <% } else { %>
            <div class="welcome-message"><%= headerUserName %>님, 환영합니다.</div>
            
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/images/user.png" alt="User" class="dropdown-toggle" onclick="toggleDropdown()">
                <div id="myDropdown" class="dropdown-content">
                    <a href="mypage.jsp">마이페이지</a>
                    <a href="member?cmd=logout">로그아웃</a>
                </div>
            </div>
            
            <input type="button" value="" onclick="location.href='trade?cmd=notification'"
                style="background: url('<%= request.getContextPath() %>/images/bell.png') no-repeat center;
                background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;"
            />
        <% } %>
    </div>
</header>