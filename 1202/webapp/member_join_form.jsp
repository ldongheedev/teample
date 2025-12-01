<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <style>
        /* 기존 스타일 유지 */
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f9f9f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            color: #333;
        }
        .join-container {
            width: 500px;
            background-color: #ffffff;
            border: 1px solid #ccc;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        h2 {
            text-align: center;
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 20px;
        }
        .section-title {
            font-weight: 700;
            margin-bottom: 10px;
            border-bottom: 2px solid #333;
            display: inline-block;
            padding-bottom: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            border-top: 2px solid #333;
        }
        td {
            border: 1px solid #ccc;
            padding: 15px 10px;
            vertical-align: middle;
        }
        table tr td:first-child {
            width: 30%;
            background-color: #f4f4f4;
            font-weight: 500;
            padding-left: 20px;
        }
        .required::before {
            content: "*";
            color: red; 
            margin-right: 5px;
            font-size: 14px;
        }
        input[type="text"],
        input[type="password"],
        input[type="email"] {
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        input[name="id"] { width: 180px; margin-right: 5px; }
        input[name="pw"], input[name="pw_check"], input[name="phone"] { width: 180px; }
        input[name="nickname"] { width: 180px; margin-right: 5px; }
        input[name="email"], input[name="addr_detail"] { width: 100%; }
        
        .address-row input[name="addr_zip"] { width: 100px; margin-right: 5px; }
        
        .zipcode-btn, .check-btn {
            padding: 10px 15px;
            background-color: #a0a0a0;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .zipcode-btn:hover, .check-btn:hover { background-color: #888888; }
        
        .button-area {
            text-align: center;
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 20px;
        }
        .button-area input[type="button"] {
            padding: 12px 30px;
            border: 1px solid #ccc;
            background-color: #ffffff;
            color: #333;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .button-area input[type="button"]:hover { background-color: #f0f0f0; }
        .button-area input[type="submit"] {
            padding: 12px 30px;
            background-color: #81c147;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .button-area input[type="submit"]:hover { background-color: #6a9c39; }
    </style>
    
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

    <script>
    var isIdChecked = false;
    var isNicknameChecked = false;
    
    function resetIdCheck() {
        isIdChecked = false;
        document.forms[0]["id"].readOnly = false;
    }

    function resetNicknameCheck() {
        isNicknameChecked = false;
        document.forms[0]["nickname"].readOnly = false;
    }

    // ✨ [수정됨] 타입(type)을 받아서 집주소/거래주소 구분
    function searchAddress(type) {
        new daum.Postcode({
            oncomplete: function(data) {
                var roadAddr = data.roadAddress; 
                var extraRoadAddr = ''; 

                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraRoadAddr += data.bname;
                }
                if(data.buildingName !== '' && data.apartment === 'Y'){
                   extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                if(extraRoadAddr !== '') extraRoadAddr = ' (' + extraRoadAddr + ')';
                
                var fullAddr = roadAddr + extraRoadAddr;

                // 타입에 따라 넣을 곳 결정
                if (type === 'home') {
                    document.getElementsByName('addr_zip')[0].value = data.zonecode; 
                    document.getElementsByName('addr_base')[0].value = fullAddr; 
                    document.getElementsByName('addr_detail')[0].focus();
                } else {
                    // 거래 희망 장소 (우편번호 없이 주소만 저장)
                    document.getElementsByName('trade_addr')[0].value = fullAddr;
                }
            }
        }).open();
    }

    function validateForm() {
        var form = document.forms[0];
        var requiredFields = [
            { name: "id", message: "아이디를 입력해주세요." },
            { name: "pw", message: "비밀번호를 입력해주세요." },
            { name: "pw_check", message: "비밀번호 확인을 입력해주세요." },
            { name: "nickname", message: "닉네임을 입력해주세요." },
            { name: "phone", message: "전화번호를 입력해주세요." },
            { name: "addr_zip", message: "주소를 검색하여 입력해주세요." },
            { name: "addr_base", message: "기본 주소를 입력해주세요." }
        ];

        for (var i = 0; i < requiredFields.length; i++) {
            var field = form[requiredFields[i].name];
            if (field && field.value.trim() === "") {
                alert(requiredFields[i].message);
                field.focus();
                return false;
            }
        }
        
        if (!isIdChecked) {
            alert("아이디 중복 확인을 해주세요.");
            form["id"].focus();
            return false;
        }

        if (form["pw"].value !== form["pw_check"].value) {
            alert("비밀번호와 비밀번호 확인 값이 일치하지 않습니다.");
            form["pw_check"].focus();
            return false;
        }
        
        if (!isNicknameChecked) {
            alert("닉네임 중복 확인을 해주세요.");
            form["nickname"].focus();
            return false;
        }

        return true;
    }
    
    // ✨ [수정됨] Controller로 연결 (member?cmd=checkId)
    function checkId() {
        var idInput = document.forms[0]["id"];
        var id = idInput.value.trim();

        if (id === "") {
            alert("아이디를 먼저 입력해주세요.");
            idInput.focus();
            return;
        }
        
        var xhr = new XMLHttpRequest();
        // 기존 id_check.jsp 대신 Controller 호출
        xhr.open("GET", "member?cmd=checkId&id=" + encodeURIComponent(id), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = xhr.responseText.trim();
                if (response === "true") {
                    alert("사용 가능한 아이디입니다.");
                    isIdChecked = true;
                    idInput.readOnly = true;
                } else {
                    alert("이미 사용 중인 아이디입니다.");
                    isIdChecked = false;
                    idInput.focus();
                }
            }
        };
        xhr.send();
    }
    
    // 닉네임 중복 확인 (기존 nickname_check.jsp 사용)
    function checkNickname() {
        var nicknameInput = document.forms[0]["nickname"];
        var nickname = nicknameInput.value.trim();

        if (nickname === "") {
            alert("닉네임을 먼저 입력해주세요.");
            nicknameInput.focus();
            return;
        }
        
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "nickname_check.jsp?nickname=" + encodeURIComponent(nickname), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var response = xhr.responseText.trim();
                if (response === "true") {
                    alert("사용 가능한 닉네임입니다.");
                    isNicknameChecked = true;
                    nicknameInput.readOnly = true;
                } else {
                    alert("이미 사용 중인 닉네임입니다.");
                    isNicknameChecked = false;
                    nicknameInput.focus();
                }
            }
        };
        xhr.send();
    }
    </script>
</head>
<body>

<div class="join-container">
    <h2>회원가입</h2>
    <div class="section-title">기본정보</div>

    <form action="member" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="cmd" value="join">
        
        <table>
            <tr>
                <td class="required">아이디</td>
                <td>
                    <input type="text" name="id" placeholder="아이디를 입력하세요" oninput="resetIdCheck()">
                    <input type="button" value="아이디 확인" class="check-btn" onclick="checkId()">
                </td>
            </tr>
            <tr>
                <td class="required">비밀번호</td>
                <td>
                    <input type="password" name="pw" placeholder="비밀번호를 입력하세요">
                </td>
            </tr>
            <tr>
                <td class="required">비밀번호 확인</td>
                <td>
                    <input type="password" name="pw_check" placeholder="비밀번호를 다시 입력하세요">
                </td>
            </tr>
            <tr>
                <td class="required">닉네임</td>
                <td>
                    <input type="text" name="nickname" placeholder="닉네임을 입력하세요" oninput="resetNicknameCheck()">
                    <input type="button" value="닉네임 확인" class="check-btn" onclick="checkNickname()">
                </td>
            </tr>
            <tr>
                <td>이메일</td>
                <td>
                    <input type="email" name="email" placeholder="예: user@example.com">
                </td>
            </tr>
            <tr>
                <td class="required">전화번호 확인</td>
                <td>
                    <input type="text" name="phone" placeholder="숫자만 입력">
                </td>
            </tr>
            <tr>
                <td class="required">주소</td>
                <td class="address-row">
                    <div>
                        <input type="text" name="addr_zip" placeholder="우편번호" readonly>
                        <input type="button" value="우편번호 찾기" class="zipcode-btn" onclick="searchAddress('home')">
                    </div>
                    <div style="margin-top: 10px;">
                        <input type="text" name="addr_base" placeholder="기본 주소" style="width: 100%; margin-bottom: 5px;" readonly>
                        <input type="text" name="addr_detail" placeholder="상세 주소">
                    </div>
                </td>
            </tr>
            
            <tr>
                <td class="required">거래 희망 장소</td>
                <td class="address-row">
                    <div style="margin-bottom:5px; color:#666; font-size:12px;">※ 직거래 시 상대방에게 노출되는 위치입니다.</div>
                    <input type="text" name="trade_addr" placeholder="예: 강남역 1번출구" style="width: 70%;" readonly>
                    <input type="button" value="장소 검색" class="zipcode-btn" onclick="searchAddress('trade')">
                </td>
            </tr>
        </table>    
        
        <div class="button-area">
            <input type="button" value="취소" onclick="window.close()"> 
            <input type="submit" value="회원가입"> 
        </div>
    </form>
</div>

</body>
</html>