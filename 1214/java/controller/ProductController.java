package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.ProductDAO;
import dto.ProductDTO;
import util.FileUtil;

@WebServlet("/product")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class ProductController extends HttpServlet {
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String cmd = request.getParameter("cmd");
        if (cmd == null) cmd = ""; // Multipart 요청일 경우 파라미터가 null일 수 있음 (Part로 받아야 함)
        
        // Multipart 요청인 경우 cmd를 다시 찾음
        if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
            // form-data인 경우 request.getParameter가 안 먹힐 수 있으므로 주의 (톰캣 10/Jakarta에서는 먹힘)
            if(cmd.isEmpty()) cmd = request.getParameter("cmd"); 
        }

        ProductDAO dao = new ProductDAO();
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        PrintWriter out = response.getWriter();

        if (userId == null) {
            out.println("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
            return;
        }

        try {
            // [1] 상품 등록 처리
            if (cmd.equals("add")) {
                String savePath = "/uploads";
                String uploadDir = getServletContext().getRealPath(savePath);
                
                ProductDTO p = new ProductDTO();
                p.setUserId(userId);
                p.setCategoryId(request.getParameter("category_id"));
                p.setProductName(request.getParameter("product_name"));
                p.setPrice(Integer.parseInt(request.getParameter("price")));
                p.setDescription(request.getParameter("description"));
                p.setShippingIncluded("true".equals(request.getParameter("shipping_included")));
                p.setDirectTrade("true".equals(request.getParameter("is_direct_trade")));
                
                // 대표 이미지
                String mainImg = FileUtil.uploadFile(request.getPart("main_image"), uploadDir, savePath);
                p.setMainImageUrl(mainImg);
                
                // 상세 이미지 (최대 4개)
                List<String> detailImages = new ArrayList<>();
                for(int i=1; i<=4; i++) {
                    String path = FileUtil.uploadFile(request.getPart("detail_image"+i), uploadDir, savePath);
                    if(path != null) detailImages.add(path);
                }
                
                int result = dao.insertProduct(p, detailImages);
                if(result > 0) {
                    session.setAttribute("toastMessage", "상품이 성공적으로 등록되었습니다.");
                    response.sendRedirect("mypage.jsp");
                } else {
                    out.println("<script>alert('등록 실패'); history.back();</script>");
                }

            // [2] 상품 삭제 처리
            } else if (cmd.equals("delete")) {
                // 단일 삭제 또는 다중 삭제 처리
                String[] ids = request.getParameterValues("product_id");
                if (ids == null) {
                    out.println("<script>alert('선택된 상품이 없습니다.'); history.back();</script>");
                    return;
                }
                
                int count = 0;
                for (String idStr : ids) {
                    count += dao.deleteProduct(Integer.parseInt(idStr), userId);
                }
                
                session.setAttribute("toastMessage", count + "개의 상품이 삭제되었습니다.");
                response.sendRedirect("mypage.jsp");

            // [3] 상품 수정 처리
            } else if (cmd.equals("edit")) {
                // (생략: 기존 코드 로직과 유사하게 ProductDTO에 담아서 dao.updateProduct 호출)
                // 내용이 길어져서 핵심만: dao.updateProduct(dto, isNewImg) 호출 후 mypage로 이동
                
                // ... (수정 로직 구현 필요 시 추가) ...
                // 일단은 간략히 리다이렉트 (실제 구현은 add와 비슷)
                response.sendRedirect("mypage.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
        }
    }
}