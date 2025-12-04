package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.ProductDAO;
import dao.TradeDAO;
import dao.NotificationDAO; 
import dto.ProductDTO;
import dto.TradeDTO;
import dto.NotificationDTO; 

@WebServlet("/trade")
public class TradeController extends HttpServlet {
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8"); 
        
        String cmd = request.getParameter("cmd");
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        TradeDAO tradeDao = new TradeDAO();
        PrintWriter out = response.getWriter();

        if (userId == null) {
            if ("request".equals(cmd) || "complete".equals(cmd)) {
                out.print("{\"status\":\"fail\", \"message\":\"로그인이 필요한 서비스입니다.\"}");
            } else {
                response.setContentType("text/html; charset=UTF-8");
                out.print("<script>alert('로그인이 필요합니다.'); location.href='loginpage.jsp';</script>");
            }
            return;
        }

        try {
            if ("request".equals(cmd)) {
                String pIdStr = request.getParameter("product_id");
                if(pIdStr == null) { out.print("{\"status\":\"fail\", \"message\":\"정보 오류\"}"); return; }
                int productId = Integer.parseInt(pIdStr);
                ProductDAO pDao = new ProductDAO();
                ProductDTO p = pDao.getProduct(productId);
                
                if (p == null) { out.print("{\"status\":\"fail\", \"message\":\"상품 없음\"}"); return; }
                if (p.getUserId().equals(userId)) { out.print("{\"status\":\"fail\", \"message\":\"내 상품 거래 불가\"}"); return; }
                
                int result = tradeDao.requestTrade(productId, userId, p.getUserId());
                if (result > 0) out.print("{\"status\":\"success\", \"message\":\"요청 완료\"}");
                else if (result == -1) out.print("{\"status\":\"fail\", \"message\":\"이미 요청함\"}");
                else out.print("{\"status\":\"fail\", \"message\":\"실패\"}");

            } else if ("notification".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8");
                int pageSize = 5;
                
                String tradePageStr = request.getParameter("tradePage");
                int tradePage = (tradePageStr == null) ? 1 : Integer.parseInt(tradePageStr);
                int tradeStart = (tradePage - 1) * pageSize;
                
                String notiPageStr = request.getParameter("notiPage");
                int notiPage = (notiPageStr == null) ? 1 : Integer.parseInt(notiPageStr);
                int notiStart = (notiPage - 1) * pageSize;

                int tradeCount = tradeDao.getReceivedTradeCount(userId);
                List<TradeDTO> received = tradeDao.getTradeList(userId, "SELLER", tradeStart, pageSize);
                
                NotificationDAO notiDao = new NotificationDAO();
                int notiCount = notiDao.getNotificationCount(userId);
                List<NotificationDTO> generalList = notiDao.getMyNotifications(userId, notiStart, pageSize);
                
                // 구매자 요청 결과는 상위 10개만
                List<TradeDTO> sent = tradeDao.getTradeList(userId, "BUYER", 0, 10); 

                int totalTradePages = (int) Math.ceil((double)tradeCount / pageSize);
                int totalNotiPages = (int) Math.ceil((double)notiCount / pageSize);

                request.setAttribute("receivedList", received);
                request.setAttribute("sentList", sent);
                request.setAttribute("generalList", generalList);
                request.setAttribute("tradePage", tradePage);
                request.setAttribute("totalTradePages", totalTradePages);
                request.setAttribute("notiPage", notiPage);
                request.setAttribute("totalNotiPages", totalNotiPages);
                
                request.getRequestDispatcher("notifications.jsp").forward(request, response);

            } else if ("decide".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8");
                int tradeId = Integer.parseInt(request.getParameter("trade_id"));
                String decision = request.getParameter("decision"); 
                tradeDao.updateStatus(tradeId, decision);
                response.sendRedirect("trade?cmd=notification");

            } else if ("complete".equals(cmd)) {
                int productId = Integer.parseInt(request.getParameter("product_id"));
                int result = tradeDao.completeTrade(productId, userId);
                if (result > 0) out.print("{\"status\":\"success\", \"message\":\"거래 완료\"}");
                else out.print("{\"status\":\"fail\", \"message\":\"권한 없음\"}");

            } else if ("list".equals(cmd)) {
                response.setContentType("text/html; charset=UTF-8");
                // ✨ [수정 완료] 이제 여기서 에러 안 남 (DAO에 메서드 오버로딩 추가함)
                List<TradeDTO> myTrades = tradeDao.getTradeList(userId, "BUYER"); 
                request.setAttribute("tradeList", myTrades);
                request.getRequestDispatcher("trade_list.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            if ("request".equals(cmd) || "complete".equals(cmd)) {
                String errorMsg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "오류";
                out.print("{\"status\":\"error\", \"message\":\"서버 오류: " + errorMsg + "\"}");
            } else {
                response.setContentType("text/html; charset=UTF-8");
                out.println("<script>alert('오류 발생'); history.back();</script>");
            }
        }
    }
}