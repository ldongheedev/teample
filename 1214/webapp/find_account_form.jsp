<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>계정 찾기</title>
    <style>
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
        .find-container {
            width: 420px;
            background-color: #ffffff;
            border: 1px solid #ccc;
            padding: 30px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            border-radius: 8px;
        }
        h2 {
            text-align: center;
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 25px;
            color: #2c7be5;
        }
        
        /* 탭 스타일 */
        .tab-menu {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 2px solid #ddd;
        }
        .tab-btn {
            flex: 1;
            padding: 12px;
            text-align: center;
            cursor: pointer;
            font-weight: 500;
            background-color: #f1f1f1;
            color: #888;
            border: 1px solid #ddd;
            border-bottom: none;
        }
        .tab-btn.active {
            background-color: #fff;
            color: #2c7be5;
            font-weight: 700;
            border: 2px solid #2c7be5;
            border-bottom: 2px solid #fff; 
            margin-bottom: -2px;
            border-radius: 5px 5px 0 0;
        }

        .form-section { display: none; }
        .form-section.active { display: block; }

        label {
            display: block;
            font-weight: 500;
            margin-bottom: 5px;
            margin-top: 15px;
            font-size: 14px;
        }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .btn-submit {
            width: 100%;
            padding: 12px;
            margin-top: 25px;
            background-color: #81c147; 
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-submit:hover { background-color: #6a9c39; }
        
        .info-text {
            font-size: 12px;
            color: #666;
            margin-top: 10px;
            line-height: 1.4;
        }
    </style>
    <script>
        function showTab(mode) {
            // 탭 버튼 스타일 초기화
            document.getElementById('btn-id').classList.remove('active');
            document.getElementById('btn-pw').classList.remove('active');
            
            // 폼 영역 초기화
            document.getElementById('form-id').classList.remove('active');
            document.getElementById('form-pw').classList.remove('active');

            // 선택된 탭 활성화
            document.getElementById('btn-' + mode).classList.add('active');
            document.getElementById('form-' + mode).classList.add('active');
        }
    </script>
</head>
<body>

<div class="find-container">
    <h2>계정 찾기</h2>

    <div class="tab-menu">
        <div id="btn-id" class="tab-btn active" onclick="showTab('id')">아이디 찾기</div>
        <div id="btn-pw" class="tab-btn" onclick="showTab('pw')">비밀번호 찾기</div>
    </div>

    <div id="form-id" class="form-section active">
        <form action="find_account_action.jsp" method="post">
            <input type="hidden" name="mode" value="find_id">
            
            <label>닉네임</label>
            <input type="text" name="nickname" placeholder="가입 시 등록한 닉네임" required>
            
            <label>이메일</label>
            <input type="email" name="email" placeholder="가입 시 등록한 이메일" required>
            
            <button type="submit" class="btn-submit">아이디 찾기</button>
        </form>
    </div>

    <div id="form-pw" class="form-section">
        <form action="find_account_action.jsp" method="post">
            <input type="hidden" name="mode" value="find_pw">
            
            <label>아이디</label>
            <input type="text" name="id" placeholder="아이디를 입력하세요" required>
            
            <label>닉네임</label>
            <input type="text" name="nickname" placeholder="가입 시 등록한 닉네임" required>
            
            <label>이메일</label>
            <input type="email" name="email" placeholder="가입 시 등록한 이메일" required>
            
            <button type="submit" class="btn-submit">비밀번호 찾기</button>
            <p class="info-text">※ 가입하신 정보와 일치해야 비밀번호를 확인할 수 있습니다.</p>
        </form>
    </div>
</div>

</body>
</html>