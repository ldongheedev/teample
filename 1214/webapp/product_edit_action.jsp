<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.nio.file.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 로그인 확인
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

    // 2. 파일 저장 경로 설정
    String savePath = application.getRealPath("/uploads/product"); // 실제 서버 경로
    File fileDir = new File(savePath);
    if (!fileDir.exists()) {
        fileDir.mkdirs(); // 폴더 없으면 생성
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // 3. 파라미터 받기
        String pIdStr = request.getParameter("product_id");
        String categoryId = request.getParameter("category_id");
        String pName = request.getParameter("product_name");
        String pPriceStr = request.getParameter("price");
        String pDesc = request.getParameter("description");
        
        // 옵션 값 받기 (문자열 -> 불리언 변환)
        String shippingStr = request.getParameter("shipping_included");
        String directTradeStr = request.getParameter("is_direct_trade"); // ✨ [추가] 직거래 파라미터
        
        // 유효성 검사
        if (pIdStr == null || pName == null) {
            out.println("<script>alert('데이터 전송 오류 (Multipart 설정 확인 필요)'); history.back();</script>");
            return;
        }

        int pId = Integer.parseInt(pIdStr);
        int pPrice = Integer.parseInt(pPriceStr);
        boolean shippingIncluded = Boolean.parseBoolean(shippingStr);
        boolean isDirectTrade = Boolean.parseBoolean(directTradeStr); // ✨ [추가] 변환

        // 4. 대표 이미지 파일 처리
        Part mainPart = request.getPart("main_image");
        String mainFileName = getFileName(mainPart);
        String mainImageUrl = null;

        if (mainFileName != null && !mainFileName.isEmpty()) {
            String savedName = UUID.randomUUID().toString() + "_" + mainFileName;
            mainPart.write(savePath + File.separator + savedName);
            mainImageUrl = "/uploads/product/" + savedName;
        }

        // 5. DB 연결 및 트랜잭션 시작
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); // 트랜잭션 시작

        // 6. Product 테이블 업데이트 (직거래 여부 컬럼 추가됨)
        String sql = "UPDATE Product SET category_id=?, product_name=?, price=?, description=?, shipping_included=?, is_direct_trade=? ";
        
        // 새 이미지가 있을 때만 이미지 컬럼 업데이트
        if (mainImageUrl != null) {
            sql += ", main_image_url=? ";
        }
        sql += " WHERE product_id=? AND user_id=?";

        pstmt = conn.prepareStatement(sql);
        int idx = 1;
        pstmt.setString(idx++, categoryId);
        pstmt.setString(idx++, pName);
        pstmt.setInt(idx++, pPrice);
        pstmt.setString(idx++, pDesc);
        pstmt.setBoolean(idx++, shippingIncluded);
        pstmt.setBoolean(idx++, isDirectTrade); // ✨ [추가] SQL 파라미터 바인딩
        
        if (mainImageUrl != null) {
            pstmt.setString(idx++, mainImageUrl);
        }
        
        pstmt.setInt(idx++, pId);
        pstmt.setString(idx++, userId); // 본인 확인

        int result = pstmt.executeUpdate();
        pstmt.close();

        if (result == 0) {
            conn.rollback();
%>
            <script>
                alert("수정에 실패했습니다. 본인의 상품이 아니거나 오류가 발생했습니다.");
                history.back();
            </script>
<%
            return;
        }

        // 7. 상세 이미지 처리 (새로 업로드된 것만 추가)
        String sqlDetail = "INSERT INTO ProductImage (product_id, image_url, display_order) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sqlDetail);

        for (int i = 1; i <= 4; i++) {
            Part detailPart = request.getPart("detail_image" + i);
            String detailFileName = getFileName(detailPart);
            
            if (detailFileName != null && !detailFileName.isEmpty()) {
                String savedDetailName = UUID.randomUUID().toString() + "_" + detailFileName;
                detailPart.write(savePath + File.separator + savedDetailName);
                String detailUrl = "/uploads/product/" + savedDetailName;

                pstmt.setInt(1, pId);
                pstmt.setString(2, detailUrl);
                pstmt.setInt(3, i);
                pstmt.executeUpdate();
            }
        }

        conn.commit(); // 트랜잭션 확정
%>
        <script>
            alert("상품 정보가 수정되었습니다.");
            location.href = "mypage.jsp";
        </script>
<%

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
%>
        <script>
            alert("시스템 오류 발생: <%= e.getMessage().replace("\"", "'") %>");
            history.back();
        </script>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<%!
    // 파일명 추출 유틸리티
    private String getFileName(Part part) {
        if (part == null) return null;
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
    }
%>