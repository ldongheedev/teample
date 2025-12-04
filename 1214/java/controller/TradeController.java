package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.ProductDAO;
import dao.TradeDAO;
import dto.ProductDTO;
import dto.TradeDTO;

@WebServlet("/trade")
public class TradeController extends HttpServlet {
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // 기본 응답 타입을 JSON으로 설정 (AJAX 요청이 많으므로)
        response.setContentType("application/json; charset=UTF-8"); 
        
        String cmd = request.getParameter("cmd");
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        TradeDAO tradeDao = new TradeDAO();
        PrintWriter out = response.getWriter();

        // 1. 로그인 체크 (AJAX 요청에 대한 방어)
        if (userId == null) {
            // 로그인 페이지로 튕겨내는 스크립트 대신 JSON으로 실패 응답을 보냄 (화면에서 처리)
            if ("request".equals(cmd) || "complete".equals(cmd)) {
                out.print("{\"status\":\"fail\", \"message\":\"로그인이 필요한 서비스입니다.\"}");
            } else {
                // 페이지 이동 요청인 경우 스크립트 전송
                response.setContentType("text/html; charset=UTF-8");
                out.print("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
            }
            return;
        }

        try {
            // [1] 거래 요청 (구매자 -> 판매자)
            if ("request".equals(cmd)) {
                String pIdStr = request.getParameter("product_id");
                if(pIdStr == null) {
                    out.print("{\"status\":\"fail\", \"message\":\"상품 정보가 올바르지 않습니다.\"}");
                    return;
                }
                
                int productId = Integer.parseInt(pIdStr);
                
                // 본인 상품 체크
                ProductDAO pDao = new ProductDAO();
                ProductDTO p = pDao.getProduct(productId);
                
                if (p == null) {
                    out.print("{\"status\":\"fail\", \"message\":\"존재하지 않는 상품입니다.\"}");
                    return;
                }
                
                if (p.getUserId().equals(userId)) {
                    out.print("{\"status\":\"fail\", \"message\":\"자신의 상품은 거래할 수 없습니다.\"}");
                    return;
                }
                
                int result = tradeDao.requestTrade(productId, userId, p.getUserId());
                if (result > 0) out.print("{\"status\":\"success\", \"message\":\"거래 요청을 보냈습니다.\"}");
                else if (result == -1) out.print("{\"status\":\"fail\", \"message\":\"이미 요청한 상품입니다.\"}");
                else out.print("{\"status\":\"fail\", \"message\":\"요청 처리에 실패했습니다.\"}");

            // [2] 알림 페이지 조회
            } else if ("notification".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8"); // 화면 이동이므로 HTML 타입
                List<TradeDTO> received = tradeDao.getTradeList(userId, "SELLER");
                List<TradeDTO> sent = tradeDao.getTradeList(userId, "BUYER");
                
                request.setAttribute("receivedList", received);
                request.setAttribute("sentList", sent);
                request.getRequestDispatcher("notifications.jsp").forward(request, response);

            // [3] 거래 수락/거절
            } else if ("decide".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8");
                int tradeId = Integer.parseInt(request.getParameter("trade_id"));
                String decision = request.getParameter("decision"); 
                
                tradeDao.updateStatus(tradeId, decision);
                response.sendRedirect("trade?cmd=notification");

            // [4] 거래 완료 처리
            } else if ("complete".equals(cmd)) {
                int productId = Integer.parseInt(request.getParameter("product_id"));
                int result = tradeDao.completeTrade(productId, userId);
                
                if (result > 0) out.print("{\"status\":\"success\", \"message\":\"거래가 완료되었습니다.\"}");
                else out.print("{\"status\":\"fail\", \"message\":\"처리 실패: 권한이 없거나 이미 완료된 상품입니다.\"}");

            // [5] 거래 내역 조회
            } else if ("list".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8");
                List<TradeDTO> myTrades = tradeDao.getTradeList(userId, "BUYER");
                request.setAttribute("tradeList", myTrades);
                request.getRequestDispatcher("trade_list.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace(); // 서버 콘솔에 에러 로그 출력
            
            // ✨ [핵심 수정] 에러가 나면 빈 화면 대신 에러 메시지(JSON)를 보냄
            // AJAX 요청일 경우에만 JSON으로 응답
            if ("request".equals(cmd) || "complete".equals(cmd)) {
                // 따옴표(") 충돌 방지 처리
                String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "알 수 없는 오류";
                out.print("{\"status\":\"error\", \"message\":\"서버 오류 발생: " + errorMsg + "\"}");
            } else {
                response.setContentType("text/html; charset=UTF-8");
                out.println("<script>alert('처리 중 오류가 발생했습니다.'); history.back();</script>");
            }
        }
    }
}