<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // 1. (신규) 비밀번호 인증 확인
    Boolean isVerified = (Boolean) session.getAttribute("pw_verified");
    
    // 2. 세션에서 사용자 ID 가져오기 (이 코드는 이미 있을 수 있음)
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

    // 3. (신규) 인증되지 않은 접근 차단
    // (pw_verified 플래그가 없거나 false이면)
    if (isVerified == null || !isVerified) {
%>
        <script>
            alert("비밀번호 인증이 필요합니다. \n정보 수정을 위해 비밀번호를 다시 입력해주세요.");
            location.href = "member_check_pw_form.jsp";
        </script>
<%
        return;
    }

    // 4. (신규) 인증 완료 후 세션 플래그 제거 (매우 중요)
    // (이 페이지에서 '새로고침'하면 다시 인증을 요구하게 됨)
    session.removeAttribute("pw_verified");

    // ----- 이 아래부터 기존 member_update_form.jsp 코드 시작 -----
    // (예: Connection, PreparedStatement, DB에서 회원정보 조회 로직...)
%>


<%
    Connection conn = null;
PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String nickname = "";
    String email = "";
    String phone = "";
String addrZip = "";
    String addrBase = "";
    String addrDetail = "";
try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
String sql = "SELECT nickname, email, phone, addr_zip, addr_base, addr_detail FROM member WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
pstmt.setString(1, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            nickname = (rs.getString("nickname") != null) ?
rs.getString("nickname") : "";
            email = (rs.getString("email") != null) ? rs.getString("email") : "";
            phone = (rs.getString("phone") != null) ?
rs.getString("phone") : "";
            addrZip = (rs.getString("addr_zip") != null) ? rs.getString("addr_zip") : "";
            addrBase = (rs.getString("addr_base") != null) ?
rs.getString("addr_base") : "";
            addrDetail = (rs.getString("addr_detail") != null) ? rs.getString("addr_detail") : "";
}
        
    } catch (Exception e) {
        e.printStackTrace();
} finally {
        if (rs != null) try { rs.close();
} catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close();
} catch (SQLException ignore) {}
        if (conn != null) try { conn.close();
} catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 회원정보 수정</title>
    
    <style>
        /* [ ... 기존 CSS 스타일 동일 ... ] */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
body {
            margin: 0;
            font-family: 'Noto Sans KR', sans-serif;
background-color: #f9f9f9;
            color: #333;
        }
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
        .mypage-wrapper {
            display: flex;
max-width: 1400px;
            min-height: 70vh;
            margin: 20px auto;
            gap: 20px;
        }
        .mypage-sidebar {
            width: 220px;
flex-shrink: 0;
            background-color: #ffffff;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
            height: fit-content;
}
        .mypage-sidebar h3 {
            font-size: 18px;
color: #333;
            margin-top: 0;
            margin-bottom: 10px;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
}
        .mypage-sidebar ul {
            list-style: none;
padding: 0;
            margin: 0 0 20px 0;
        }
        .mypage-sidebar li a {
            display: block;
padding: 12px 15px;
            text-decoration: none;
            color: #555;
            font-size: 15px;
            border-radius: 6px;
}
        .mypage-sidebar li a:hover {
            background-color: #f5f5f5;
}
        .mypage-sidebar li.active a {
            background-color: #81c147;
color: white;
            font-weight: 500;
        }
        .mypage-content {
            flex-grow: 1;
background-color: #ffffff;
            padding: 30px 40px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-radius: 8px;
}
        .mypage-content h2 {
            font-size: 24px;
margin-top: 0;
            margin-bottom: 25px;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
}
        .update-form table {
            width: 100%;
border-collapse: collapse;
            border-top: 2px solid #333;
        }
        .update-form th, .update-form td {
            padding: 15px;
border-bottom: 1px solid #eee;
        }
        .update-form th {
            width: 150px;
background-color: #fcfcfc;
            text-align: left;
            vertical-align: middle;
            font-weight: 500;
        }
        .update-form .required::before {
            content: "*";
color: red; 
            margin-right: 5px;
        }
        .update-form input[type="text"], .update-form input[type="password"], .update-form input[type="email"], .update-form select {
            width: 100%;
padding: 10px;
            font-size: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
}
        .update-form input[readonly] {
            background-color: #f0f0f0;
color: #777;
        }
        .address-row input[name="addr_zip"] {
             width: 120px;
margin-right: 10px;
        }
        .zipcode-btn {
            padding: 10px 15px;
background-color: #a0a0a0;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
}
        .form-buttons {
            display: flex;
justify-content: center;
            gap: 15px;
            margin-top: 30px;
        }
        .form-buttons input {
            padding: 12px 30px;
font-size: 16px;
            font-weight: 500;
            border-radius: 5px;
            border: 1px solid #ccc;
            cursor: pointer;
}
        .form-buttons input[type="submit"] {
            background-color: #81c147;
color: white;
            border-color: #81c147;
        }
        .form-buttons input[type="button"] {
            background-color: #fff;
color: #333;
        }
        .pw-check-message {
            font-size: 12px;
margin-top: 5px;
            display: block;
        }
        .pw-check-message.success {
            color: green;
}
        .pw-check-message.error {
            color: red;
}
        footer {
            background-color: #f1f1f1;
padding: 40px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #555;
            margin-top: 50px;
}
        .footer-section h4 {
            margin-bottom: 10px;
font-weight: bold;
        }
        .footer-section p, .footer-section a {
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
    
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
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
        
        function searchAddress() {
            new daum.Postcode({
                oncomplete: function(data) {
               

                     var roadAddr = data.roadAddress; 
                    var extraRoadAddr = ''; 

                    if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                        extraRoadAddr += data.bname;
 
                
                    }
                    if(data.buildingName !== '' && data.apartment === 'Y'){
                       if(extraRoadAddr !== ''){
             
              extraRoadAddr += ', ' + data.buildingName;
              
                       } else {
                           extraRoadAddr += data.buildingName;
             
          }
                    }
                 
                     if(extraRoadAddr !== ''){
                        extraRoadAddr = ' (' + extraRoadAddr 
+ ')';
                    }

                    document.forms[0]['addr_zip'].value = data.zonecode;
document.forms[0]['addr_base'].value = roadAddr + extraRoadAddr; 
                    document.forms[0]['addr_detail'].focus();
                }
            }).open();
}
        
        function checkNewPasswordMatch() {
            var newPw = document.forms[0].new_pw.value;
var newPwConfirm = document.forms[0].new_pw_confirm.value;
            var msgSpan = document.getElementById("pw_check_msg");

            if (newPwConfirm === "") {
                msgSpan.innerText = "";
msgSpan.className = "pw-check-message";
                return;
            }
            
            if (newPw === newPwConfirm) {
                msgSpan.innerText = "새 비밀번호가 일치합니다.";
msgSpan.className = "pw-check-message success";
            } else {
                msgSpan.innerText = "새 비밀번호가 일치하지 않습니다.";
msgSpan.className = "pw-check-message error";
            }
        }

        function validateUpdateForm() {
            var form = document.forms[0];
var requiredFields = [
                { name: "current_pw", message: "현재 비밀번호를 입력해주세요."
},
                { name: "email", message: "이메일을 입력해주세요."
},
                { name: "phone", message: "전화번호를 입력해주세요."
}
            ];
for (var i = 0; i < requiredFields.length; i++) {
                var field = form[requiredFields[i].name];
if (field && field.value.trim() === "") {
                    alert(requiredFields[i].message);
field.focus();
                    return false;
                }
            }
            
            if (form.new_pw.value !== "" && (form.new_pw.value !== form.new_pw_confirm.value)) {
                alert("새 비밀번호와 새 비밀번호 확인이 일치하지 않습니다.");
form.new_pw_confirm.focus();
                return false;
            }
            if (form.new_pw.value === "" && form.new_pw_confirm.value !== "") {
                alert("새 비밀번호를 먼저 입력해주세요.");
form.new_pw.focus();
                return false;
            }

            var originalPhone = document.getElementById("original_phone").value.replace(/[^0-9]/g, "");
var currentPhone = document.getElementById("phone").value.replace(/[^0-9]/g, "");
            var isVerified = document.getElementById("phone_verified").value;

            if (originalPhone !== currentPhone && isVerified !== "true") {
                alert("전화번호가 변경되었습니다. 인증을 완료해주세요.");
document.getElementById("phone").focus();
                return false;
            }

            return true;
}

        function formatPhone(input) {
            var digits = input.value.replace(/[^0-9]/g, "");
digits = digits.substring(0, 11);
            var formatted = "";
            if (digits.length > 7) {
                formatted = digits.substring(0, 3) + "-" + digits.substring(3, 7) + "-" + digits.substring(7);
} else if (digits.length > 3) {
                formatted = digits.substring(0, 3) + "-" + digits.substring(3);
} else {
                formatted = digits;
}
            input.value = formatted;

            var originalPhone = document.getElementById("original_phone").value.replace(/[^0-9]/g, "");
var currentPhone = digits;
            var btnSend = document.getElementById("btn_send_code");
            var authArea = document.getElementById("auth_code_area");
            var verifiedStatus = document.getElementById("phone_verified");

            if (currentPhone !== originalPhone) {
                verifiedStatus.value = "false";

                document.getElementById("btn_confirm_code").disabled = false;
document.getElementById("user_auth_code").value = "";
                document.getElementById("user_auth_code").disabled = false;
                
                if (currentPhone.length >= 10) {
                    btnSend.style.display = "inline-block";
} else {
                    btnSend.style.display = "none";
}
            } else {
                btnSend.style.display = "none";
authArea.style.display = "none";
                verifiedStatus.value = "false"; 
            }
        }
        
        function sendAuthCode() {
    
        var code = Math.floor(1000 + Math.random() * 9000);

            document.getElementById("server_auth_code").value = code;

            alert("인증번호 [" + code + "]를 입력해주세요.");
document.getElementById("auth_code_area").style.display = "block";
            document.getElementById("user_auth_code").focus();
        }

        function confirmAuthCode() {
            var serverCode = document.getElementById("server_auth_code").value;
var userCode = document.getElementById("user_auth_code").value;

            if (serverCode !== "" && serverCode === userCode) {
                alert("인증에 성공했습니다.");
document.getElementById("phone_verified").value = "true"; 
                
                document.getElementById("user_auth_code").disabled = true;
document.getElementById("btn_confirm_code").disabled = true;
                document.getElementById("btn_send_code").style.display = "none";
            } else {
                alert("인증번호가 일치하지 않습니다. 다시 시도해주세요.");
document.getElementById("server_auth_code").value = ""; 
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="logo">
            <a href="main_page.jsp">
    		    <img src="<%= request.getContextPath() %>/images/logo.png" style="height: 60px; width: 200px; object-fit: contain;">
            </a>
		</div>
        <div class="header-links">
     
       <div class="welcome-message">
                <%= (String)session.getAttribute("userName") %>님, 
                환영합니다.
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
               background-size: contain; width: 40px; height: 40px; border: none; cursor: pointer;"
/>
        </div>
    </header>
    
    <div class="mypage-wrapper">
        
        <nav class="mypage-sidebar">
            <h3>회원정보</h3>
            <ul>
                <li class="active"><a href="member_update_form.jsp">정보 수정</a></li>
                <li><a href="member_delete_form.jsp">회원 탈퇴</a></li>
 

            </ul>
            <h3>쇼핑정보</h3>
				<ul>
				    <li><a href="wishlist.jsp">찜리스트</a></li>
				    <li><a href="#">거래조회</a></li>
				</ul>
            <h3>상품관리</h3>
      
 
             <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
            <h3>고객센터</h3>
       
     <ul>
    
                <li><a href="#">1:1 문의</a></li>
                <li><a href="#">FAQ</a></li>
            </ul>
        </nav>
        
        <main class="mypage-content">
            <h2>회원정보 수정</h2>
      
      
       
             <form class="update-form" action="member_update_action.jsp" method="post" onsubmit="return validateUpdateForm();">
                <table>
                    <tbody>
                        <tr>
         
                   <th>아이디</th>
  
                             <td>
                                <input type="text" name="id" value="<%= userId %>" readonly>
            
                </td>
        
                         </tr>
                        <tr>
                           
 <th>닉네임</th>
                            <td>
    
                                 <input type="text" name="nickname" value="<%= nickname %>" readonly>
                            
</td>
                        </tr>
              
                     <tr>
                            <th class="required">현재 비밀번호</th>
           
                 <td>
                                
                                <input type="password" name="current_pw" placeholder="정보 수정을 위해 현재 비밀번호를 입력하세요" required>
          
                  </td>
                        </tr>
                        <tr>
               
                   
      <th>새 비밀번호</th>
                            <td>
                                <input type="password" name="new_pw" placeholder="변경할 경우에만 입력하세요" onkeyup="checkNewPasswordMatch()">
                    
       
              </td>
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
        
                             <td>
                                <input type="email" name="email" value="<%= 
email %>" required>
                            </td>
              
                     </tr>
                        <tr>
           
                 <th class="required">전화번호</th>
                            
                            <td>
                          
      <input type="text" name="phone" id="phone" value="<%= phone %>" required 
                                   onkeyup="formatPhone(this)" maxlength="13" 
                                   placeholder="010-1234-5678 형식으로 입력">
            
                    
                                <input type="button" value="인증번호" id="btn_send_code" class="zipcode-btn"
                                   style="display:none;
margin-left:10px; background-color:#2c7be5;" 
                                   onclick="sendAuthCode()">
                                
                               
 <div id="auth_code_area" style="display:none; margin-top:10px;">
                                    <input type="text" id="user_auth_code" placeholder="인증번호 4자리 입력" style="width: 160px;
margin-right: 10px;">
                                    <input type="button" value="확인" id="btn_confirm_code" class="zipcode-btn" onclick="confirmAuthCode()">
                                </div>
                          
      
                                <input type="hidden" id="original_phone" value="<%= phone %>">
                                <input type="hidden" id="server_auth_code" value="">
                      
          <input type="hidden" id="phone_verified" value="false">
                            </td>
                            </tr>
                   
            
         <tr>
                            <th>주소</th>
                            <td class="address-row">
                                <div>
  
    
                                   <input type="text" name="addr_zip" value="<%= addrZip %>" placeholder="우편번호" readonly>
                                    <input type="button" value="우편번호 찾기" class="zipcode-btn" onclick="searchAddress()">
             
         
                         </div>
                                <div style="margin-top: 10px;">
                                
    <input type="text" name="addr_base" value="<%= addrBase %>" placeholder="기본 주소" style="width: 100%;
margin-bottom: 5px;" readonly>
                                    <input type="text" name="addr_detail" value="<%= addrDetail %>" placeholder="상세 주소">
                                </div>
                       

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

    <footer>
 
         <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px;
width: 200px; float: left;" />
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
		<div style="display: flex;
gap: 40px;">
    		<div class="footer-section">
        		<h4>ABOUT</h4>
        		<a href="company_intro.jsp"> <%= companyIntro %> </a><br>
        		<a href="notice_list.jsp"> <%= notice %> </a><br>
    		</div>
    		<div class="footer-section">
        		<h4>SUPPORT</h4>
        		<a href="#"> <%= question %> </a><br>
        		<a href="#"> <%= faq %> </a>
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