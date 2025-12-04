package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.TradeDTO;
import util.DBManager;

public class TradeDAO {

    // 1. 거래 요청
    public int requestTrade(int productId, String buyerId, String sellerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String checkSql = "SELECT trade_id FROM TradeRequest WHERE product_id=? AND buyer_id=?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, buyerId);
            rs = pstmt.executeQuery();
            if (rs.next()) return -1; 
            
            DBManager.close(null, pstmt, rs);
            
            conn.setAutoCommit(false); 
            
            String sql = "INSERT INTO TradeRequest (product_id, buyer_id, seller_id, status, requested_at) VALUES (?, ?, ?, 'REQUESTED', NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, buyerId);
            pstmt.setString(3, sellerId);
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            if(result > 0) {
                String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, 'TRADE', '내 상품에 새로운 거래 요청이 도착했습니다.', 'trade?cmd=notification', NOW())";
                pstmt = conn.prepareStatement(notiSql);
                pstmt.setString(1, sellerId);
                pstmt.executeUpdate();
            }
            conn.commit();
            return result;
        } catch (Exception e) { 
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            e.printStackTrace(); 
        } finally { 
            try { if(conn!=null) conn.setAutoCommit(true); } catch(SQLException ex){}
            DBManager.close(conn, pstmt, rs); 
        }
        return 0;
    }

    // 2. 거래 상태 변경
    public int updateStatus(int tradeId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false); 

            String sql = "UPDATE TradeRequest SET status = ?, accepted_at = NOW() WHERE trade_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, tradeId);
            int result = pstmt.executeUpdate();
            pstmt.close();

            if (result > 0) {
                String selectSql = "SELECT t.buyer_id, p.product_name FROM TradeRequest t JOIN Product p ON t.product_id = p.product_id WHERE t.trade_id = ?";
                pstmt = conn.prepareStatement(selectSql);
                pstmt.setInt(1, tradeId);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    String buyerId = rs.getString("buyer_id");
                    String pName = rs.getString("product_name");
                    String msg = "ACCEPTED".equals(status) ? "'" + pName + "' 거래 요청이 수락되었습니다." : "'" + pName + "' 거래 요청이 거절되었습니다.";
                    
                    String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, 'TRADE', ?, 'trade?cmd=list', NOW())";
                    PreparedStatement notiPstmt = conn.prepareStatement(notiSql);
                    notiPstmt.setString(1, buyerId);
                    notiPstmt.setString(2, msg);
                    notiPstmt.executeUpdate();
                    notiPstmt.close();
                }
            }
            conn.commit(); 
            return result;
        } catch (Exception e) { 
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            e.printStackTrace(); 
        } finally { 
            try { if(conn!=null) conn.setAutoCommit(true); } catch(SQLException ex){}
            DBManager.close(conn, pstmt, rs); 
        }
        return 0;
    }

    // 3. 거래 완료
    public int completeTrade(int productId, String sellerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false); 

            String prodSql = "UPDATE Product SET is_sold_out = 1 WHERE product_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(prodSql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, sellerId);
            int pResult = pstmt.executeUpdate();
            pstmt.close();

            if(pResult > 0) {
                String tradeSql = "UPDATE TradeRequest SET status = 'COMPLETED' WHERE product_id = ? AND status = 'ACCEPTED'";
                pstmt = conn.prepareStatement(tradeSql);
                pstmt.setInt(1, productId);
                pstmt.executeUpdate();
                pstmt.close();
                
                String findBuyerSql = "SELECT buyer_id, (SELECT product_name FROM Product WHERE product_id=?) as pname FROM TradeRequest WHERE product_id=? AND status='COMPLETED'";
                pstmt = conn.prepareStatement(findBuyerSql);
                pstmt.setInt(1, productId);
                pstmt.setInt(2, productId);
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    String buyerId = rs.getString("buyer_id");
                    String pName = rs.getString("pname");
                    String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, 'TRADE', ?, 'trade?cmd=list', NOW())";
                    PreparedStatement notiPstmt = conn.prepareStatement(notiSql);
                    notiPstmt.setString(1, buyerId);
                    notiPstmt.setString(2, "'" + pName + "' 거래가 완료되었습니다.");
                    notiPstmt.executeUpdate();
                    notiPstmt.close();
                }
            }
            conn.commit();
            return pResult;
        } catch (Exception e) { 
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            e.printStackTrace(); 
        } finally { 
            try { if(conn!=null) conn.setAutoCommit(true); } catch(SQLException ex){}
            DBManager.close(conn, pstmt, rs); 
        }
        return 0;
    }

    // ✨ [추가] 거래 요청 개수 (페이징용)
    public int getReceivedTradeCount(String sellerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        try {
            conn = DBManager.getConnection();
            String sql = "SELECT COUNT(*) FROM TradeRequest WHERE seller_id = ? AND status = 'REQUESTED'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sellerId);
            rs = pstmt.executeQuery();
            if(rs.next()) count = rs.getInt(1);
        } catch(Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, rs); }
        return count;
    }

    // ✨ [수정] 거래 목록 조회 (페이징 버전)
    public List<TradeDTO> getTradeList(String userId, String role, int startRow, int pageSize) {
        List<TradeDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql = "";
            
            if ("SELLER".equals(role)) {
                sql = "SELECT tr.*, p.product_name, p.main_image_url, m.nickname AS other_nick, m.phone AS other_phone FROM TradeRequest tr JOIN Product p ON tr.product_id = p.product_id JOIN member m ON tr.buyer_id = m.id WHERE tr.seller_id = ? AND tr.status = 'REQUESTED' ORDER BY tr.requested_at DESC LIMIT ?, ?";
            } else {
                sql = "SELECT tr.*, p.product_name, p.main_image_url, m.nickname AS other_nick, m.phone AS other_phone FROM TradeRequest tr JOIN Product p ON tr.product_id = p.product_id JOIN member m ON tr.seller_id = m.id WHERE tr.buyer_id = ? ORDER BY tr.requested_at DESC LIMIT ?, ?";
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, startRow);
            pstmt.setInt(3, pageSize);
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

    // ✨ [추가] 거래 목록 조회 (페이징 없는 구버전 호환용 - 오류 해결의 핵심!)
    public List<TradeDTO> getTradeList(String userId, String role) {
        // 페이징 없이 부르면 그냥 최근 100개 가져오도록 처리
        return getTradeList(userId, role, 0, 100);
    }
}