
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <style>
        /* 웹폰트 - Noto Sans KR */
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
            border: 1px solid #ccc; /* 전체적인 테두리 */
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

        /* 테이블 스타일 */
        table {
            width: 100%;
            border-collapse: collapse;
            border-top: 2px solid #333; /* 상단 구분선 */
        }

        td {
            border: 1px solid #ccc;
            padding: 15px 10px;
            vertical-align: middle;
        }

        table tr td:first-child {
            /* 라벨 (아이디, 비밀번호 등) 영역 */
            width: 30%;
            background-color: #f4f4f4; /* 배경색 살짝 회색 */
            font-weight: 500;
            padding-left: 20px;
        }
        
        /* 필수 항목에 별표 표시 스타일 (★로 변경했습니다. 이전 코드가 *였지만, 이미지에 더 가까워보입니다.) */
        .required::before {
            content: "*";
            color: red; /* 퍼스널 컬러 */
            margin-right: 5px;
            font-size: 14px;
        }

        /* 입력 필드 스타일 */
        input[type="text"],
        input[type="password"],
        input[type="email"] {
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        /* 개별 입력 필드 너비 조정 */
        input[name="id"], 
        input[name="pw"],
        input[name="pw_check"],
        input[name="phone"] {
            width: 180px; /* 이미지 속 짧은 필드 */
        }

        input[name="email"],
        input[name="addr_detail"] {
            width: 100%; /* 이미지 속 긴 필드 */
        }

        /* 주소 필드 레이아웃 */
        .address-row input[name="addr_zip"] {
             width: 100px; 
             margin-right: 5px;
        }
        
        /* 우편번호 찾기 버튼 */
        .zipcode-btn {
            padding: 10px 15px;
            background-color: #a0a0a0; /* 회색 버튼 */
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .zipcode-btn:hover {
            background-color: #888888;
        }

        /* 버튼 영역 */
        .button-area {
            text-align: center;
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        /* 취소 버튼 */
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
        
        .button-area input[type="button"]:hover {
            background-color: #f0f0f0;
        }

        /* 회원가입 (등록) 버튼 - 81c147 */
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
        
        .button-area input[type="submit"]:hover {
            background-color: #6a9c39;
        }

    </style>
    
    <script>
    function validateForm() {
        // 폼 요소들을 가져옵니다.
        var form = document.forms[0]; 
        
        // 필수 항목 필드 목록
        var requiredFields = [
            { name: "id", message: "아이디를 입력해주세요." },
            { name: "pw", message: "비밀번호를 입력해주세요." },
            { name: "pw_check", message: "비밀번호 확인을 입력해주세요." },
            { name: "phone", message: "전화번호를 입력해주세요." },
            { name: "addr_zip", message: "주소를 검색하여 입력해주세요." },
            { name: "addr_base", message: "기본 주소를 입력해주세요." }
        ];

        // 유효성 검사 루프
        for (var i = 0; i < requiredFields.length; i++) {
            var field = form[requiredFields[i].name];
            
            // 필드 값이 비어있거나 (공백 제거 후) 길이가 0인 경우
            if (field && field.value.trim() === "") {
                alert(requiredFields[i].message);
                field.focus(); // 해당 필드로 포커스 이동
                return false; // 폼 제출 중단
            }
        }
        
        // 비밀번호와 비밀번호 확인 일치 여부 검사 (추가적인 필수 검사)
        if (form["pw"].value !== form["pw_check"].value) {
            alert("비밀번호와 비밀번호 확인 값이 일치하지 않습니다.");
            form["pw_check"].focus();
            return false;
        }

        // 모든 검사 통과 시 폼 제출 허용
        return true;
    }
    </script>
</head>
<body>

<div class="join-container">
    <h2>회원가입</h2>
    
    <div class="section-title">기본정보</div>

    <form action="member_join.jsp" method="post" onsubmit="return validateForm()">
        <table>
            <tr>
                <td class="required">아이디</td>
                <td>
                    <input type="text" name="id" placeholder="아이디를 입력하세요">
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
                        <input type="button" value="우편번호 찾기" class="zipcode-btn">
                    </div>
                    <div style="margin-top: 10px;">
                        <input type="text" name="addr_base" placeholder="기본 주소" style="width: 100%; margin-bottom: 5px;" readonly>
                        <input type="text" name="addr_detail" placeholder="상세 주소">
                    </div>
                </td>
            </tr>
        </table>    
        
        <div class="button-area">
            <input type="button" value="취소" onclick="history.back()"> 
            <input type="submit" value="회원가입"> 
        </div>
    </form>
</div>

</body>
</html>
