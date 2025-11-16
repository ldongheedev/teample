<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>

<%
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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 상품 삭제</title>
    
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
        .admin-header {
            display: flex;
justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 25px;
}
        .admin-header h2 {
            font-size: 24px;
margin: 0;
        }
        .delete-btn {
            background-color: #d9534f;
color: white;
            border: none;
            padding: 10px 20px;
            font-size: 15px;
            font-weight: 500;
            border-radius: 5px;
            cursor: pointer;
}
        .delete-btn:hover {
            background-color: #c9302c;
}
        .product-grid {
            display: grid;
grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }
        .product-card {
            background-color: #fff;
border: 1px solid #eee;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            padding: 15px;
            position: relative;
}
        .product-card-checkbox {
            position: absolute;
top: 10px;
            right: 10px;
            transform: scale(1.3);
        }
        .product-card img {
            width: 100%;
height: 200px;
            object-fit: contain;
            background-color: #ffffff;
            border-radius: 4px;
            margin-bottom: 10px;
}
        .product-card .info {
            padding: 0;
}
        .product-card .info .name {
            font-size: 16px;
font-weight: 500;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .product-card .info .price {
            font-size: 15px;
font-weight: bold;
            color: #333;
            margin-top: 5px;
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
        
        function confirmDelete() {
            const checkedCount = document.querySelectorAll('input[name="product_id"]:checked').length;
if (checkedCount === 0) {
                alert("삭제할 상품을 1개 이상 선택하세요.");
return false;
            }
            return confirm("선택한 " + checkedCount + "개의 상품을 정말 삭제하시겠습니까?\n삭제된 상품 데이터는 복구할 수 없습니다.");
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
                <li><a href="member_update_form.jsp">정보 수정</a></li>
                <li><a href="member_delete_form.jsp">회원 탈퇴</a></li>
  
              </ul>
            
            <h3>쇼핑정보</h3>
				<ul>
				    <li><a href="wishlist.jsp">찜리스트</a></li>
                	<li><a href="trade_list.jsp">거래조회</a></li>
				</ul>
				    
 
            
            <h3>상품관리</h3>
            <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li><a href="mypage.jsp">상품 정보 수정</a></li>
                <li class="active"><a href="product_delete_form.jsp">상품 삭제</a></li>
       
     </ul>

 
            <h3>고객센터</h3>
            <ul>
                <li><a href="#">1:1 문의</a></li>
                <li><a href="faq_list.jsp">FAQ</a></li>
            </ul>
        </nav>
        
       
 <main class="mypage-content">
     
            <form action="product_delete_action.jsp" method="post" onsubmit="return confirmDelete();">
                <div class="admin-header">
                    <h2>상품 삭제</h2>
                    <button type="submit" class="delete-btn">선택 상품 삭제하기</button>
               
 </div>
           
            
                <div class="product-grid">
                    <%
                        Connection conn = null;
PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        boolean hasProducts = false;
                        DecimalFormat formatter = new DecimalFormat("#,###");
try {
                            Class.forName("org.mariadb.jdbc.Driver");
conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
                            
                            String sql = "SELECT product_id, product_name, price, main_image_url FROM Product WHERE user_id = ? ORDER BY created_at DESC";
pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, userId); 
                            rs = pstmt.executeQuery();

                            while (rs.next()) {
                                hasProducts = true;
String pName = rs.getString("product_name");
                                int pPrice = rs.getInt("price");
                                String pImage = rs.getString("main_image_url");
                                int pId = rs.getInt("product_id");
if (pImage == null || pImage.trim().isEmpty()) {
                                    pImage = request.getContextPath() + "/images/logo.png";
} else {
                                    pImage = request.getContextPath() + pImage;
}
                    %>
                            <div class="product-card">
                                <input type="checkbox" name="product_id" value="<%= pId %>" class="product-card-checkbox">
             

                                <a href="product_detail.jsp?product_id=<%= pId %>" target="_blank">
                                    <img src="<%= pImage %>" alt="<%= pName %>">
                      
          </a>
   
                                 <div class="info">
                                    <p class="name"><%= pName %></p>
              
                 
                                     <p class="price"><%= formatter.format(pPrice) %>원</p>
                                </div>
           
                 </div>
                    <%
            
                        }
                           
 
                            if (!hasProducts) {
                          
                         out.println("<p>등록된 상품이 없습니다.</p>");
}

                        } catch (Exception e) {
                            e.printStackTrace();
out.println("<p style='color:red;'>상품 목록을 불러오는 중 오류가 발생했습니다. (DB: " + e.getMessage() + ")</p>");
} finally {
                            if (rs != null) try { rs.close();
} catch (SQLException ignore) {}
                            if (pstmt != null) try { pstmt.close();
} catch (SQLException ignore) {}
                            if (conn != null) try { conn.close();
} catch (SQLException ignore) {}
                        }
                    %>
                </div>
            </form>
        </main>
    </div>

    <footer>
        

         <div class="footer-section">
            <img src="<%= request.getContextPath() %>/images/logo2.png" style="height: 80px; width: 200px; float: left;"
/>
            <p>(주) 중고모아 |
대표 김령균</p>
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
        		<a href="#"> <%= question %> </a><br>
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