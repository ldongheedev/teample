package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.NotificationDTO;
import util.DBManager;

public class NotificationDAO {

    // 1. 알림 등록 (기존 동일)
    public int insertNotification(String userId, String type, String message, String url) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, type);
            pstmt.setString(3, message);
            pstmt.setString(4, url);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    // ✨ [추가] 2-1. 내 알림 전체 개수 조회 (페이징용)
    public int getNotificationCount(String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        try {
            conn = DBManager.getConnection();
            String sql = "SELECT COUNT(*) FROM Notification WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if(rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return count;
    }

    // ✨ [수정] 2-2. 내 알림 목록 조회 (페이징 적용)
    // startRow: 시작 인덱스(0부터), pageSize: 가져올 개수
    public List<NotificationDTO> getMyNotifications(String userId, int startRow, int pageSize) {
        List<NotificationDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            // LIMIT {시작점}, {개수}
            String sql = "SELECT * FROM Notification WHERE user_id = ? ORDER BY created_at DESC LIMIT ?, ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, startRow);
            pstmt.setInt(3, pageSize);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                NotificationDTO n = new NotificationDTO();
                n.setNotiId(rs.getInt("noti_id"));
                n.setUserId(rs.getString("user_id"));
                n.setType(rs.getString("type"));
                n.setMessage(rs.getString("message"));
                n.setUrl(rs.getString("url"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return list;
    }
}