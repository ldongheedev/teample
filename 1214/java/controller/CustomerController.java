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
        if (cmd == null) cmd = "noticeList"; 
        
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
                response.sendRedirect("customer?cmd=inquiryList"); // 목록으로 이동 (또는 상세로)

            // --- [추가] 상세 조회 ---
            } else if (cmd.equals("inquiryDetail")) {
                int id = Integer.parseInt(request.getParameter("id"));
                InquiryDTO inquiry = dao.getInquiry(id);
                
                if(inquiry == null) {
                    out.println("<script>alert('존재하지 않는 글입니다.'); location.href='customer?cmd=inquiryList';</script>");
                    return;
                }
                
                request.setAttribute("inquiry", inquiry);
                request.getRequestDispatcher("inquiry_detail.jsp").forward(request, response);

            // --- [추가] 문의 수정 ---
            } else if (cmd.equals("inquiryUpdate")) {
                if(userId == null) { response.sendRedirect("loginpage.jsp"); return; }
                
                int id = Integer.parseInt(request.getParameter("inquiry_id"));
                InquiryDTO dto = new InquiryDTO();
                dto.setInquiryId(id);
                dto.setUserId(userId); // 본인 확인용
                dto.setCategory(request.getParameter("category"));
                dto.setTitle(request.getParameter("title"));
                dto.setContent(request.getParameter("content"));
                
                int result = dao.updateInquiry(dto);
                
                if (result > 0) {
                    session.setAttribute("toastMessage", "문의 내용이 수정되었습니다.");
                    response.sendRedirect("customer?cmd=inquiryDetail&id=" + id);
                } else {
                    out.println("<script>alert('수정 실패: 답변이 완료되었거나 본인 글이 아닙니다.'); history.back();</script>");
                }

            // --- [추가] 문의 삭제 ---
            } else if (cmd.equals("inquiryDelete")) {
                if(userId == null) { response.sendRedirect("loginpage.jsp"); return; }
                
                int id = Integer.parseInt(request.getParameter("id"));
                int result = dao.deleteInquiry(id, userId, isManager);
                
                if (result > 0) {
                    session.setAttribute("toastMessage", "문의글이 삭제되었습니다.");
                    response.sendRedirect("customer?cmd=inquiryList");
                } else {
                    out.println("<script>alert('삭제 권한이 없습니다.'); history.back();</script>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
        }
    }
}