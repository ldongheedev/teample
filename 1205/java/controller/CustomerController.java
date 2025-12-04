package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.CustomerDAO;
import dto.InquiryDTO;
import dto.NoticeDTO;

@WebServlet("/customer")
public class CustomerController extends HttpServlet {
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String cmd = request.getParameter("cmd");
        if (cmd == null) cmd = "noticeList"; // 기본값
        
        CustomerDAO dao = new CustomerDAO();
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String isAdmin = (String) session.getAttribute("isAdmin");
        boolean isManager = "true".equals(isAdmin);
        PrintWriter out = response.getWriter();

        try {
            // ================= [공지사항] =================
            if (cmd.equals("noticeList")) {
                String sort = request.getParameter("sort");
                List<NoticeDTO> list = dao.getNoticeList(sort);
                request.setAttribute("noticeList", list);
                request.getRequestDispatcher("notice_list.jsp").forward(request, response);

            } else if (cmd.equals("noticeDetail")) {
                int id = Integer.parseInt(request.getParameter("id"));
                NoticeDTO notice = dao.getNotice(id);
                request.setAttribute("notice", notice);
                request.getRequestDispatcher("notice_detail.jsp").forward(request, response);

            } else if (cmd.equals("noticeWrite")) {
                if(!isManager) { out.print("<script>alert('권한이 없습니다.'); history.back();</script>"); return; }
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                dao.insertNotice(title, content, userId);
                response.sendRedirect("customer?cmd=noticeList");

            } else if (cmd.equals("noticeUpdate")) {
                if(!isManager) { out.print("<script>alert('권한이 없습니다.'); history.back();</script>"); return; }
                int id = Integer.parseInt(request.getParameter("notice_id"));
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                dao.updateNotice(id, title, content);
                response.sendRedirect("customer?cmd=noticeDetail&id=" + id);

            } else if (cmd.equals("noticeDelete")) {
                if(!isManager) { out.print("<script>alert('권한이 없습니다.'); history.back();</script>"); return; }
                int id = Integer.parseInt(request.getParameter("notice_id"));
                dao.deleteNotice(id);
                response.sendRedirect("customer?cmd=noticeList");

            // ================= [1:1 문의] =================
            } else if (cmd.equals("inquiryList")) {
                if(userId == null) { response.sendRedirect("loginpage.jsp"); return; }
                List<InquiryDTO> list = dao.getInquiryList(userId, isManager);
                request.setAttribute("inquiryList", list);
                request.getRequestDispatcher("inquiry_list.jsp").forward(request, response);

            } else if (cmd.equals("inquiryDetail")) {
                // (상세 보기 로직은 list 페이지 내에 모달/아코디언으로 있어서 데이터만 잘 넘기면 됨)
                response.sendRedirect("customer?cmd=inquiryList");

            } else if (cmd.equals("inquiryWrite")) {
                if(userId == null) { response.sendRedirect("loginpage.jsp"); return; }
                InquiryDTO dto = new InquiryDTO();
                dto.setUserId(userId);
                dto.setCategory(request.getParameter("category"));
                dto.setTitle(request.getParameter("title"));
                dto.setContent(request.getParameter("content"));
                dao.insertInquiry(dto);
                out.println("<script>alert('문의가 등록되었습니다.'); location.href='customer?cmd=inquiryList';</script>");

            } else if (cmd.equals("inquiryAnswer")) {
                if(!isManager) { out.print("<script>alert('권한이 없습니다.'); history.back();</script>"); return; }
                int id = Integer.parseInt(request.getParameter("inquiry_id"));
                String answer = request.getParameter("answer");
                dao.answerInquiry(id, answer);
                response.sendRedirect("customer?cmd=inquiryList");
            
            // ✨ [추가] 1:1 문의 삭제 기능
            } else if (cmd.equals("inquiryDelete")) {
                // 1. 관리자 권한 체크
                if (!isManager) {
                    out.println("<script>alert('권한이 없습니다.'); history.back();</script>");
                    return;
                }
                
                // 2. 파라미터 받기
                String idStr = request.getParameter("inquiry_id");
                if (idStr == null) {
                    out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
                    return;
                }
                
                // 3. 삭제 실행
                int id = Integer.parseInt(idStr);
                int result = dao.deleteInquiry(id);

                // 4. 결과 처리
                if (result > 0) {
                    out.println("<script>alert('해당 문의가 삭제되었습니다.'); location.href='customer?cmd=inquiryList';</script>");
                } else {
                    out.println("<script>alert('삭제 실패'); history.back();</script>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
        }
    }
}