package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.MemberDAO;
import dto.MemberDTO;

@WebServlet("/member")
public class MemberController extends HttpServlet {
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String cmd = request.getParameter("cmd");
        if (cmd == null) cmd = "";
        
        MemberDAO dao = new MemberDAO();
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        try {
            // [1] 로그인 처리
            if (cmd.equals("login")) {
                String id = request.getParameter("id");
                String pw = request.getParameter("pw");
                
                if(id == null || pw == null) {
                    out.println("<script>alert('아이디와 비밀번호를 입력해주세요.'); history.back();</script>");
                    return;
                }

                int result = dao.loginCheck(id, pw);
                
                if (result == 1) { 
                    MemberDTO member = dao.getMember(id);
                    if (member != null) {
                        session.setAttribute("userId", member.getId());
                        session.setAttribute("userName", member.getNickname());
                        session.setAttribute("isAdmin", member.getIsAdmin());
                        response.sendRedirect("main_page.jsp");
                    } else {
                        out.println("<script>alert('회원 정보를 불러오는데 실패했습니다.'); history.back();</script>");
                    }
                } else if (result == 0) {
                    out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
                } else if (result == -1) {
                    out.println("<script>alert('존재하지 않는 아이디입니다.'); history.back();</script>");
                } else if (result == -2) {
                    out.println("<script>alert('정지된 계정입니다.'); location.href='main_page.jsp';</script>");
                } else {
                    out.println("<script>alert('시스템 오류가 발생했습니다.'); history.back();</script>");
                }
                
            // [2] 로그아웃 처리
            } else if (cmd.equals("logout")) {
                session.invalidate();
                response.sendRedirect("main_page.jsp");
                
            // [3] 아이디 중복 체크 (AJAX)
            } else if (cmd.equals("checkId")) {
                String id = request.getParameter("id");
                boolean exist = dao.isIdExist(id);
                response.setContentType("text/plain");
                out.print(exist ? "false" : "true"); 
                
            // [4] 회원가입 처리 (✨ 여기를 수정했습니다!)
            } else if (cmd.equals("join")) {
                MemberDTO dto = new MemberDTO();
                dto.setId(request.getParameter("id"));
                dto.setPw(request.getParameter("pw"));
                dto.setNickname(request.getParameter("nickname"));
                dto.setEmail(request.getParameter("email"));
                dto.setPhone(request.getParameter("phone"));
                dto.setAddrZip(request.getParameter("addr_zip"));
                dto.setAddrBase(request.getParameter("addr_base"));
                dto.setAddrDetail(request.getParameter("addr_detail"));
                dto.setTradeAddr(request.getParameter("trade_addr")); 
                
                int result = dao.insertMember(dto);
                
                if(result > 0) {
                    // ✨ [수정] 성공 메시지 변경 및 창 닫기 스크립트 적용
                    out.println("<script>");
                    out.println("alert('회원가입이 완료 되었습니다. 로그인 후 이용해주세요.');");
                    // 부모 창(로그인 페이지)이 열려있다면 새로고침
                    out.println("if(window.opener && !window.opener.closed) { window.opener.location.href = 'loginpage.jsp'; }");
                    // 현재 팝업창 닫기
                    out.println("window.close();");
                    out.println("</script>");
                } else {
                    out.println("<script>alert('가입 실패. 입력 정보를 확인해주세요.'); history.back();</script>");
                }
            
            // [5] 회원정보 수정
            } else if (cmd.equals("update")) {
                String userId = (String) session.getAttribute("userId");
                if(userId == null) { response.sendRedirect("loginpage.jsp"); return; }
                
                String newPw = request.getParameter("new_pw");
                boolean updatePw = (newPw != null && !newPw.trim().isEmpty());
                
                MemberDTO dto = new MemberDTO();
                dto.setId(userId);
                dto.setEmail(request.getParameter("email"));
                dto.setPhone(request.getParameter("phone"));
                dto.setAddrZip(request.getParameter("addr_zip"));
                dto.setAddrBase(request.getParameter("addr_base"));
                dto.setAddrDetail(request.getParameter("addr_detail"));
                dto.setTradeAddr(request.getParameter("trade_addr"));
                if(updatePw) dto.setPw(newPw);
                
                dao.updateMember(dto, updatePw);
                session.setAttribute("toastMessage", "정보가 수정되었습니다.");
                response.sendRedirect("mypage.jsp");

            } else {
                out.println("<h3>잘못된 요청입니다. (cmd=" + cmd + ")</h3>");
                out.println("<a href='main_page.jsp'>메인으로 돌아가기</a>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('서버 내부 오류: " + e.getMessage() + "'); history.back();</script>");
        }
    }
}