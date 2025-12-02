package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.TradeDTO;
import util.DBManager;

public class TradeDAO {

    // 1. 거래 요청 (중복 체크 포함)
    public int requestTrade(int productId, String buyerId, String sellerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            // 중복 확인
            String checkSql = "SELECT trade_id FROM TradeRequest WHERE product_id=? AND buyer_id=?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, buyerId);
            rs = pstmt.executeQuery();
            if (rs.next()) return -1; // 이미 요청함
            
            DBManager.close(null, pstmt, rs);
            
            // 요청 등록
            String sql = "INSERT INTO TradeRequest (product_id, buyer_id, seller_id, status, requested_at) VALUES (?, ?, ?, 'REQUESTED', NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, buyerId);
            pstmt.setString(3, sellerId);
            return pstmt.executeUpdate();
            
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, rs); }
        return 0;
    }

    // 2. 거래 상태 변경 (수락/거절)
    public int updateStatus(int tradeId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "UPDATE TradeRequest SET status = ?, accepted_at = NOW() WHERE trade_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, tradeId);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    // 3. 거래 완료 처리 (상품 판매완료 + 거래 상태 변경)
    public int completeTrade(int productId, String sellerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false);

            // 상품 판매 완료 처리
            String prodSql = "UPDATE Product SET is_sold_out = 1 WHERE product_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(prodSql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, sellerId);
            int pResult = pstmt.executeUpdate();
            pstmt.close();

            // 거래 상태 완료로 변경 (수락된 건에 한해)
            if(pResult > 0) {
                String tradeSql = "UPDATE TradeRequest SET status = 'COMPLETED' WHERE product_id = ? AND status = 'ACCEPTED'";
                pstmt = conn.prepareStatement(tradeSql);
                pstmt.setInt(1, productId);
                pstmt.executeUpdate();
            }
            
            conn.commit();
            return pResult;
        } catch (Exception e) { 
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            e.printStackTrace(); 
        } finally { 
            try { if(conn!=null) conn.setAutoCommit(true); } catch(SQLException ex){}
            DBManager.close(conn, pstmt, null); 
        }
        return 0;
    }

    // 4. 알림/목록 조회
    // role: "SELLER"(내가 판매자-받은요청) / "BUYER"(내가 구매자-보낸요청)
    public List<TradeDTO> getTradeList(String userId, String role) {
        List<TradeDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql = "";
            
            if ("SELLER".equals(role)) {
                // 내가 판매자 -> 구매자(Buyer) 정보를 가져옴
                sql = "SELECT tr.*, p.product_name, p.main_image_url, m.nickname AS other_nick, m.phone AS other_phone " +
                      "FROM TradeRequest tr " +
                      "JOIN Product p ON tr.product_id = p.product_id " +
                      "JOIN member m ON tr.buyer_id = m.id " +
                      "WHERE tr.seller_id = ? AND tr.status = 'REQUESTED' ORDER BY tr.requested_at DESC";
            } else {
                // 내가 구매자 -> 판매자(Seller) 정보를 가져옴
                sql = "SELECT tr.*, p.product_name, p.main_image_url, m.nickname AS other_nick, m.phone AS other_phone " +
                      "FROM TradeRequest tr " +
                      "JOIN Product p ON tr.product_id = p.product_id " +
                      "JOIN member m ON tr.seller_id = m.id " +
                      "WHERE tr.buyer_id = ? ORDER BY tr.requested_at DESC";
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                TradeDTO t = new TradeDTO();
                t.setTradeId(rs.getInt("trade_id"));
                t.setProductId(rs.getInt("product_id"));
                t.setStatus(rs.getString("status"));
                t.setRequestedAt(rs.getTimestamp("requested_at"));
                t.setAcceptedAt(rs.getTimestamp("accepted_at"));
                
                t.setProductName(rs.getString("product_name"));
                t.setMainImageUrl(rs.getString("main_image_url"));
                t.setOtherNickname(rs.getString("other_nick"));
                t.setOtherPhone(rs.getString("other_phone"));
                list.add(t);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, rs); }
        return list;
    }
}