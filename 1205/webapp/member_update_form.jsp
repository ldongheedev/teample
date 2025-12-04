<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, util.DBManager, dto.MemberDTO, dao.MemberDAO" %>

<%
    // 1. 비밀번호 인증 확인 (인증 안했으면 튕겨냄)
    Boolean isVerified = (Boolean) session.getAttribute("pw_verified");
    String userId = (String) session.getAttribute("userId");
    
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
        return;
    }
    if (isVerified == null || !isVerified) {
        out.println("<script>alert('비밀번호 인증이 필요합니다.'); location.href='member_check_pw_form.jsp';</script>");
        return;
    }
    session.removeAttribute("pw_verified"); // 인증 토큰 1회용 소모

    // 2. 회원 정보 조회 (DAO 사용)
    MemberDAO dao = new MemberDAO();
    MemberDTO m = dao.getMember(userId);
    
    // null 처리
    String nickname = (m.getNickname() != null) ? m.getNickname() : "";
    String email = (m.getEmail() != null) ? m.getEmail() : "";
    String phone = (m.getPhone() != null) ? m.getPhone() : "";
    String addrZip = (m.getAddrZip() != null) ? m.getAddrZip() : "";
    String addrBase = (m.getAddrBase() != null) ? m.getAddrBase() : "";
    String addrDetail = (m.getAddrDetail() != null) ? m.getAddrDetail() : "";
    // ✨ 거래 주소
    String tradeAddr = (m.getTradeAddr() != null) ? m.getTradeAddr() : "";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원정보 수정</title>
    <style>
        /* 기존 CSS 유지 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333; }
        header { display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo img { height: 60px; width: 200px; object-fit: contain; }
        .header-links { display: flex; align-items: center; gap: 15px; }
        .welcome-message { font-size: 14px; color: #333; font-weight: 500; }
        .header-links a { margin-left: 20px; text-decoration: none; color: #555; font-size: 14px; }
        .dropdown { position: relative; display: inline-block; }
        .dropdown-toggle { height: 40px; width: 40px; cursor: pointer; border-radius: 50%; object-fit: cover; }
        .dropdown-content { display: none; position: absolute; right: 0; background-color: #ffffff; min-width: 120px; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); z-index: 1001; border-radius: 5px; }
        .dropdown-content a { color: #333; padding: 12px 16px; text-decoration: none; display: block; margin: 0; font-size: 14px; }
        .dropdown-content a:hover { background-color: #f1f1f1; }
        .show { display: block; }
        
        .mypage-wrapper { display: flex; max-width: 1400px; min-height: 70vh; margin: 20px auto; gap: 20px; }
        .mypage-sidebar { width: 220px; flex-shrink: 0; background-color: #ffffff; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; height: fit-content; }
        .mypage-sidebar h3 { font-size: 18px; color: #333; margin-top: 0; margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .mypage-sidebar ul { list-style: none; padding: 0; margin: 0 0 20px 0; }
        .mypage-sidebar li a { display: block; padding: 12px 15px; text-decoration: none; color: #555; font-size: 15px; border-radius: 6px; }
        .mypage-sidebar li a:hover { background-color: #f5f5f5; }
        .mypage-sidebar li.active a { background-color: #81c147; color: white; font-weight: 500; }
        
        .mypage-content { flex-grow: 1; background-color: #ffffff; padding: 30px 40px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; }
        .mypage-content h2 { font-size: 24px; margin-top: 0; margin-bottom: 25px; border-bottom: 2px solid #333; padding-bottom: 10px; }
        
        .update-form table { width: 100%; border-collapse: collapse; border-top: 2px solid #333; }
        .update-form th, .update-form td { padding: 15px; border-bottom: 1px solid #eee; }
        .update-form th { width: 150px; background-color: #fcfcfc; text-align: left; vertical-align: middle; font-weight: 500; }
        .update-form .required::before { content: "*"; color: red; margin-right: 5px; }
        .update-form input[type="text"], .update-form input[type="password"], .update-form input[type="email"] { width: 100%; padding: 10px; font-size: 15px; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; }
        .update-form input[readonly] { background-color: #f0f0f0; color: #777; }
        
        .address-row input[name="addr_zip"] { width: 120px; margin-right: 10px; }
        .zipcode-btn { padding: 10px 15px; background-color: #a0a0a0; color: white; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; }
        
        .form-buttons { display: flex; justify-content: center; gap: 15px; margin-top: 30px; }
        .form-buttons input { padding: 12px 30px; font-size: 16px; font-weight: 500; border-radius: 5px; border: 1px solid #ccc; cursor: pointer; }
        .form-buttons input[type="submit"] { background-color: #81c147; color: white; border-color: #81c147; }
        .form-buttons input[type="button"] { background-color: #fff; color: #333; }
        
        .pw-check-message { font-size: 12px; margin-top: 5px; display: block; }
        .pw-check-message.success { color: green; }
        .pw-check-message.error { color: red; }
    </style>
    
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script>
        // 헤더 드롭다운
        function toggleDropdown() { document.getElementById("myDropdown").classList.toggle("show"); }
        window.onclick = function(event) { if (!event.target.matches('.dropdown-toggle')) { var d = document.getElementsByClassName("dropdown-content"); for (var i=0; i<d.length; i++) { if (d[i].classList.contains('show')) d[i].classList.remove('show'); } } }

        // ✨ 주소 검색 (타입 구분)
        function searchAddress(type) {
            new daum.Postcode({
                oncomplete: function(data) {
                    var roadAddr = data.roadAddress; 
                    var extraRoadAddr = ''; 
                    if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)) extraRoadAddr += data.bname;
                    if(data.buildingName !== '' && data.apartment === 'Y') extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                    if(extraRoadAddr !== '') extraRoadAddr = ' (' + extraRoadAddr + ')';
                    var finalAddr = roadAddr + extraRoadAddr;

                    if (type === 'home') {
                        document.forms[0]['addr_zip'].value = data.zonecode;
                        document.forms[0]['addr_base'].value = finalAddr;
                        document.forms[0]['addr_detail'].focus();
                    } else {
                        // 거래 주소
                        document.forms[0]['trade_addr'].value = finalAddr;
                    }
                }
            }).open();
        }
        
        function checkNewPasswordMatch() {
            var newPw = document.forms[0].new_pw.value;
            var newPwConfirm = document.forms[0].new_pw_confirm.value;
            var msgSpan = document.getElementById("pw_check_msg");
            if (newPwConfirm === "") { msgSpan.innerText = ""; msgSpan.className = "pw-check-message"; return; }
            if (newPw === newPwConfirm) { msgSpan.innerText = "새 비밀번호가 일치합니다."; msgSpan.className = "pw-check-message success"; } 
            else { msgSpan.innerText = "새 비밀번호가 일치하지 않습니다."; msgSpan.className = "pw-check-message error"; }
        }

        function validateUpdateForm() {
            var form = document.forms[0];
            if (form.new_pw.value !== "" && (form.new_pw.value !== form.new_pw_confirm.value)) { alert("새 비밀번호가 일치하지 않습니다."); return false; }
            return true;
        }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" />
    
    <div class="mypage-wrapper">
        <nav class="mypage-sidebar">
            <h3>회원정보</h3>
            <ul>
                <li class="active"><a href="member_check_pw_form.jsp">정보 수정</a></li>
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
        
        <main class="mypage-content">
            <h2>회원정보 수정</h2>
            
            <form class="update-form" action="member" method="post" onsubmit="return validateUpdateForm();">
                <input type="hidden" name="cmd" value="update">
                
                <table>
                    <tbody>
                        <tr>
                            <th>아이디</th>
                            <td><input type="text" name="id" value="<%= userId %>" readonly></td>
                        </tr>
                        <tr>
                            <th>닉네임</th>
                            <td><input type="text" name="nickname" value="<%= nickname %>" readonly></td>
                        </tr>
                        <tr>
                            <th>새 비밀번호</th>
                            <td><input type="password" name="new_pw" placeholder="변경할 경우에만 입력하세요" onkeyup="checkNewPasswordMatch()"></td>
                        </tr>
                        <tr>
                            <th>새 비밀번호 확인</th>
                            <td>
                                <input type="password" name="new_pw_confirm" placeholder="새 비밀번호를 다시 입력하세요" onkeyup="checkNewPasswordMatch()">
                                <span id="pw_check_msg" class="pw-check-message"></span>
                            </td>
                        </tr>
                        <tr>
                            <th class="required">이메일</th>
                            <td><input type="email" name="email" value="<%= email %>" required></td>
                        </tr>
                        <tr>
                            <th class="required">전화번호</th>
                            <td><input type="text" name="phone" value="<%= phone %>" required></td>
                        </tr>
                        <tr>
                            <th>주소</th>
                            <td class="address-row">
                                <div>
                                    <input type="text" name="addr_zip" value="<%= addrZip %>" placeholder="우편번호" readonly>
                                    <input type="button" value="우편번호 찾기" class="zipcode-btn" onclick="searchAddress('home')">
                                </div>
                                <div style="margin-top: 10px;">
                                    <input type="text" name="addr_base" value="<%= addrBase %>" placeholder="기본 주소" style="width: 100%; margin-bottom: 5px;" readonly>
                                    <input type="text" name="addr_detail" value="<%= addrDetail %>" placeholder="상세 주소">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>거래 희망 장소</th>
                            <td class="address-row">
                                <div style="margin-bottom:5px; color:#666; font-size:12px;">※ 직거래 시 상대방에게 노출되는 위치입니다.</div>
                                <input type="text" name="trade_addr" value="<%= tradeAddr %>" placeholder="예: 강남역 1번출구" style="width: 70%;" readonly>
                                <input type="button" value="장소 검색" class="zipcode-btn" onclick="searchAddress('trade')">
                            </td>
                        </tr>
                    </tbody>
                </table>
                
                <div class="form-buttons">
                    <input type="button" value="취소" onclick="location.href='mypage.jsp'">
                    <input type="submit" value="수정하기">
                </div>
            </form>
        </main>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>