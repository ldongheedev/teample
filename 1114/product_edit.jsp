<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %> 
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.lang.StringBuilder" %>

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

<%
    String pIdStr = request.getParameter("product_id");
if (pIdStr == null || pIdStr.isEmpty()) {
%>
        <script>
            alert("잘못된 접근입니다. 상품 ID가 없습니다.");
history.back();
        </script>
<%
        return;
}
    
    int pId = Integer.parseInt(pIdStr);

    Connection conn = null;
    PreparedStatement pstmt = null;
ResultSet rs = null;
    
    String pName = "", pDesc = "", pCategoryId = "", pMainImage = "";
int pPrice = 0;
    boolean pShippingIncluded = false;
    ArrayList<String> pDetailImages = new ArrayList<>();
    StringBuilder categoryOptions = new StringBuilder();
try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
String sql = "SELECT * FROM Product WHERE product_id = ? AND user_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, pId);
pstmt.setString(2, userId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            pName = rs.getString("product_name");
pPrice = rs.getInt("price");
            pDesc = rs.getString("description");
            pCategoryId = rs.getString("category_id");
            pShippingIncluded = rs.getBoolean("shipping_included");
            pMainImage = rs.getString("main_image_url");
} else {
            rs.close();
            pstmt.close();
            conn.close();
%>
            <script>
                alert("존재하지 않거나 수정 권한이 없는 상품입니다.");
location.href = "mypage.jsp";
            </script>
<%
            return;
}
        rs.close();
        pstmt.close();
String sqlDetailImg = "SELECT image_url FROM ProductImage WHERE product_id = ? ORDER BY display_order ASC";
        pstmt = conn.prepareStatement(sqlDetailImg);
        pstmt.setInt(1, pId);
rs = pstmt.executeQuery();
        while(rs.next()) {
            pDetailImages.add(rs.getString("image_url"));
}
        rs.close();
        pstmt.close();
String sqlCategory = "SELECT category_id, category_name FROM category WHERE is_active = TRUE ORDER BY sort_order, category_name";
        pstmt = conn.prepareStatement(sqlCategory);
rs = pstmt.executeQuery();
        
        while (rs.next()) {
            String catId = rs.getString("category_id");
String catName = rs.getString("category_name");
            
            categoryOptions.append("<option value='");
            categoryOptions.append(catId);
            categoryOptions.append("'");
            
            if (catId.equals(pCategoryId)) {
                categoryOptions.append(" selected");
}
            
            categoryOptions.append(">");
categoryOptions.append(catName);
            categoryOptions.append("</option>");
        }
    } catch (Exception e) {
        e.printStackTrace();
categoryOptions.append("<option value=''>!카테고리 로딩 실패!</option>");
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
    <title>마이페이지 - 상품 수정</title>
    
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
        .product-form table {
            width: 100%;
border-collapse: collapse;
            border-top: 2px solid #333;
        }
        .product-form th, .product-form td {
            padding: 15px;
border-bottom: 1px solid #eee;
        }
        .product-form th {
            width: 150px;
background-color: #fcfcfc;
            text-align: left;
            vertical-align: top;
            font-weight: 500;
        }
        .product-form input[type="text"], .product-form input[type="number"], .product-form select, .product-form textarea {
            width: 100%;
padding: 10px;
            font-size: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
}
        .product-form textarea {
            height: 200px;
resize: vertical;
        }
        .product-form input[type="file"] {
            font-size: 14px;
margin-top: 5px;
        }
        .current-images {
            display: flex;
gap: 10px;
            margin-bottom: 15px;
        }
        .current-images .img-preview {
            width: 100px;
height: 100px;
            object-fit: contain;
            border: 1px solid #ddd;
            background-color: #f9f9f9;
            border-radius: 4px;
}
        .current-images-label {
            font-size: 13px;
color: #777;
            margin-bottom: 5px;
        }
        .image-upload-area div {
            margin-bottom: 10px;
}
        .image-upload-area label {
            font-weight: 500;
font-size: 14px;
            color: #555;
        }
        .shipping-option label {
            margin-right: 15px;
font-size: 15px;
        }
        .shipping-option input[type="radio"] {
            margin-right: 5px;
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
                <li><a href="#">찜리스트</a></li>
                <li><a href="#">거래조회</a></li>
            </ul>
            <h3>상품관리</h3>
    
 
           <ul>
                <li><a href="product_add_form.jsp">상품 등록</a></li>
                <li class="active"><a href="mypage.jsp">상품 정보 수정</a></li>
                <li><a href="product_delete_form.jsp">상품 삭제</a></li>
            </ul>
            <h3>고객센터</h3>
      
     
            <ul>
                <li><a href="#">1:1 문의</a></li>
                <li><a href="#">FAQ</a></li>
            </ul>
        </nav>
        
        <main class="mypage-content">
           
 <h2>상품 정보 수정</h2>
            
 
            <form class="product-form" action="product_edit_action.jsp" method="post" enctype="multipart/form-data">
                
                <input type="hidden" name="product_id" value="<%= pId %>">
                
               
 <table>
                
                    <tbody>
                        <tr>
                            <th>카테고리</th>
           
                 <td>
                
                                <select name="category_id" required>
                                 
   <option value="">-- 카테고리를 선택하세요 --</option>
                                    
                                    <%= categoryOptions %>
                   
                 
                                </select>
                            </td>
                       
 </tr>
                
                    <tr>
                            <th>상품명</th>
                            <td>
       
                         <input type="text" name="product_name" value="<%= 
                                pName %>" required>
                            </td>
         
               </tr>
                        <tr>
                      
                           <th>가격</th>
            
                <td>
                                <input type="number" name="price" value="<%= pPrice %>" required>
                            
                  
          </td>
                        </tr>
                        
                        <tr>
                  
          
                            <th>택배비</th>
                            <td class="shipping-option">
                                <input 
type="radio" name="shipping_included" value="false" id="ship_no" <%= (!pShippingIncluded ? "checked" : "") %>>
                            
                                <label for="ship_no">택배비 미포함 (X)</label>
                           
     
                                <input type="radio" name="shipping_included" value="true" id="ship_yes" <%= (pShippingIncluded ?
                                "checked" : "") %>>
                     
           <label for="ship_yes">택배비 포함 (O)</label>
                            </td>
                        </tr>
          
                
        
                <tr>
                            <th>상품 이미지</th>
                            <td class="image-upload-area">
    
                      
      
                                <div class="current-images">
                                    <div>
   
                      
                   <div class="current-images-label">현재 대표 이미지</div>
                                        <img src="<%= request.getContextPath() + pMainImage %>" alt="대표 이미지" class="img-preview">
            
                  
                  </div>
                                    <% if (!pDetailImages.isEmpty()) { %>
                                    
      
                              <div>
                                        <div class="current-images-label">현재 상세 이미지</div>
                           
             <% for (String imgUrl : pDetailImages) { %>
          
                                           <img src="<%= request.getContextPath() + imgUrl %>" alt="상세 이미지" class="img-preview">
                   
                     <% } %>
                
                                    </div>
                         
           <% } %>
                                </div>
          
                               
              
                  <hr style="border:0;
border-top:1px dashed #ccc; margin: 15px 0;">

                                <div>
                                    <label>대표 이미지 (새로 등록할 경우에만 선택)</label><br>
                      

                                    <input type="file" name="main_image" accept="image/*">
                                </div>
                             
   <div>
                   
                                     <label>상세 이미지 (새로 등록할 경우에만 선택)</label><br>
                                    
<input type="file" name="detail_image1" accept="image/*">
                                    <input type="file" name="detail_image2" 
                                    accept="image/*">
                      
              <input type="file" name="detail_image3" accept="image/*">
                                    <input type="file" name="detail_image4" accept="image/*">
                      
                      
       </div>
                            </td>
                        </tr>
                        <tr>
              
   
                          <th>상품 설명</th>
                            <td>
                                <textarea name="description"><%= pDesc %></textarea>
          
            
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