<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>중고모아 로그인</title>
<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');

/* --- Global & Layout --- */
body {
    margin: 0;
    font-family: 'Noto Sans KR', sans-serif;
    background-color: #f9f9f9;
    color: #333;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

/* --- Header Styles --- */
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

/* Dropdown (로그인 후 사용자 메뉴) */
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

/* --- Login Section Styles --- */
.login-section {
    flex-grow: 1; /* 중앙 컨텐츠가 남은 공간을 차지하도록 */
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 80px 0;
}

.login-section-content { /* 실제 박스 역할을 하는 컨테이너 추가 */
    max-width: 400px;
    padding: 30px 40px;
    background-color: #ffffff;
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    width: 100%;
    box-sizing: border-box;
}

.login-section h2 {
    display: none;
}

form.login-form-box {
    display: flex;
    gap: 10px;
}

.input-fields {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.input-fields input[type="text"],
.input-fields input[type="password"] {
    padding: 12px 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 14px;
}

input.login-submit-btn {
    width: 100px;
    height: 95px; /* 두 인풋 필드 높이에 맞춤 */
    padding: 10px;
    background-color: #81c147;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s ease;
    box-sizing: border-box;
}

input.login-submit-btn:hover {
    background-color: #70a93d; /* 더 진한 초록색으로 hover 효과 변경 */
}

.extra-options {
    margin-top: 20px;
    text-align: center;
    font-size: 14px;
    padding-bottom: 20px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
}

.extra-options a {
    color: #333;
    text-decoration: none;
    font-weight: 500;
}

.extra-options a:hover {
    text-decoration: underline;
}

.social-login-buttons {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 20px;
}

.social-login-buttons button,
.social-login-buttons a { /* a 태그로 변경된 네이버 버튼을 위한 스타일 추가 */
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 14px;
    cursor: pointer;
    font-weight: bold;
    transition: background-color 0.3s ease;
    text-align: center;
    text-decoration: none;
}

/* 네이버 버튼 스타일 */
.btn-naver {
    background-color: #03C75A;
    border-color: #03C75A;
    color: #FFFFFF;
}

.btn-naver:hover {
    background-color: #02b350;
}

/* 카카오 버튼 스타일 */
.btn-kakao {
    background-color: #FEE500;
    border-color: #FEE500;
    color: #000000;
}

.btn-kakao:hover {
    background-color: #e5cd00;
}

/* 로그인 상태일 때 표시되는 스타일 */
.logged-in-info {
    text-align: center;
    font-size: 16px;
    margin-bottom: 20px;
}

.logged-in-actions {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.logged-in-actions input[type="submit"],
.logged-in-actions input[type="button"] {
    padding: 10px 15px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
}

.logged-in-actions input[type="submit"] {
    background-color: #f44336;
    color: white;
}

.logged-in-actions input[type="button"] {
    background-color: #2c7be5;
    color: white;
}

/* --- Footer Styles --- */
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
</style>

<script>
// 카카오 초기화
Kakao.init('bcc79fb201a4c981b39abe52461abf5b');

function loginWithKakao() {
    Kakao.Auth.login({
        success: function(authObj) {
            Kakao.API.request({
                url: '/v2/user/me',
                success: function(res) {
                    var form = document.kakaoHiddenForm;
                    form.kakao_id.value = res.id;
                    form.nickname.value = res.properties.nickname;
                    form.email.value = res.kakao_account.email ? res.kakao_account.email : "";
                    form.submit();
                },
                fail: function(error) { alert(JSON.stringify(error)); }
            });
        },
        fail: function(err) { alert(JSON.stringify(err)); },
    });
}

function validateForm() {
    var id = document.forms[0]["id"].value;
    var pw = document.forms[0]["pw"].value;

    if (id == "" && pw == "") {
        alert("아이디와 비밀번호를 모두 입력하시오.");
        return false;
    } else if (id == "") {
        alert("아이디를 입력하시오.");
        return false;
    } else if (pw == "") {
        alert("비밀번호를 입력하시오.");
        return false;
    }
    return true;
}

function toggleDropdown() {
    document.getElementById("myDropdown").classList.toggle("show");
}

// Close the dropdown if the user clicks outside of it
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
</head>
<body>
    <header>
        <div class="logo">
            <a href="main_page.jsp">
                <img src="<%= request.getContextPath() %>/images/logo.png" />
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


    <div class="login-section">
        <div class="login-section-content">
        <%
        // JSP: 로그인 상태 확인
        String userName = (String)session.getAttribute("userName");
        if ((String)session.getAttribute("userId") != null) {
        %>
            <h2>로그인 완료</h2>
            <div class="logged-in-info">
                <%= (userName != null ? userName : (String)session.getAttribute("userId")) %>님 환영합니다!
            </div>
            <form action="logout.jsp" method="post" class="logged-in-actions">
                <input type="submit" value="로그아웃">
                <input type="button" value="회원정보수정" onclick="window.open('member_update_form.jsp','','width=500,height=200')">
            </form>
        <%
        } else {
        // JSP: 로그아웃 상태일 때 로그인 폼 표시
        %>
            <h2>로그인</h2>
            <form action="login.jsp" method="post" class="login-form-box" onsubmit="return validateForm()">
                <div class="input-fields">
                    <input type="text" name="id" placeholder="아이디">
                    <input type="password" name="pw" placeholder="비밀번호">
                </div>
                <input type="submit" value="로그인" class="login-submit-btn">
            </form>

            <div class="extra-options">
                <a href="#" onclick="window.open('member_join_form.jsp', 'joinForm', 'width=600,height=800'); return false;">회원가입</a>
                <a href="#">아이디 찾기/비밀번호 찾기</a>
            </div>
            <div class="social-login-buttons">
                <button type="button" class="btn-kakao" onclick="loginWithKakao()">카카오톡으로 로그인</button>
                <a href="naverlogin.jsp" class="btn-naver">네이버로 로그인</a>
            </div>
        <%
        }
        %>
        </div>
    </div>

    <form name="kakaoHiddenForm" action="kakao_login_action.jsp" method="post" style="display:none;">
        <input type="hidden" name="kakao_id" value="">
        <input type="hidden" name="nickname" value="">
        <input type="hidden" name="email" value="">
    </form>

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


</body>
</html>