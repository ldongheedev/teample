package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.NoticeDTO;
import dto.InquiryDTO;
import util.DBManager;

public class CustomerDAO {

    // --- [공지사항] ---
    public List<NoticeDTO> getNoticeList(String sort) {
        List<NoticeDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String orderBy = "reg_date DESC"; // 기본값
        if ("oldest".equals(sort)) orderBy = "reg_date ASC";
        else if ("id_desc".equals(sort)) orderBy = "notice_id DESC";

        try {
            conn = DBManager.getConnection();
            String sql = "SELECT * FROM Notice ORDER BY " + orderBy;
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                NoticeDTO n = new NoticeDTO();
                n.setNoticeId(rs.getInt("notice_id"));
                n.setTitle(rs.getString("title"));
                n.setWriterId(rs.getString("writer_id"));
                n.setRegDate(rs.getTimestamp("reg_date"));
                n.setViews(rs.getInt("views"));
                list.add(n);
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return list;
    }

    public NoticeDTO getNotice(int id) {
        NoticeDTO n = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            // 조회수 증가
            pstmt = conn.prepareStatement("UPDATE Notice SET views = views + 1 WHERE notice_id = ?");
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            pstmt.close();

            // 상세 조회
            pstmt = conn.prepareStatement("SELECT * FROM Notice WHERE notice_id = ?");
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                n = new NoticeDTO();
                n.setNoticeId(rs.getInt("notice_id"));
                n.setTitle(rs.getString("title"));
                n.setContent(rs.getString("content"));
                n.setWriterId(rs.getString("writer_id"));
                n.setRegDate(rs.getTimestamp("reg_date"));
                n.setViews(rs.getInt("views"));
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return n;
    }

    public int insertNotice(String title, String content, String writerId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "INSERT INTO Notice (title, content, writer_id, reg_date) VALUES (?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setString(3, writerId);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    public int updateNotice(int id, String title, String content) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "UPDATE Notice SET title=?, content=?, reg_date=NOW() WHERE notice_id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, id);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    public int deleteNotice(int id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement("DELETE FROM Notice WHERE notice_id=?");
            pstmt.setInt(1, id);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    // --- [1:1 문의] ---
    public List<InquiryDTO> getInquiryList(String userId, boolean isAdmin) {
        List<InquiryDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql;
            if (isAdmin) {
                sql = "SELECT * FROM Inquiry ORDER BY created_at DESC";
                pstmt = conn.prepareStatement(sql);
            } else {
                sql = "SELECT * FROM Inquiry WHERE user_id = ? ORDER BY created_at DESC";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userId);
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                InquiryDTO i = new InquiryDTO();
                i.setInquiryId(rs.getInt("inquiry_id"));
                i.setUserId(rs.getString("user_id"));
                i.setCategory(rs.getString("category"));
                i.setTitle(rs.getString("title"));
                i.setStatus(rs.getString("status"));
                i.setCreatedAt(rs.getTimestamp("created_at"));
                // ✨ [이 부분이 추가되었습니다!]
                i.setContent(rs.getString("content"));
                i.setAnswer(rs.getString("answer"));
                list.add(i);
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return list;
    }

    public InquiryDTO getInquiry(int id) {
        InquiryDTO i = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement("SELECT * FROM Inquiry WHERE inquiry_id = ?");
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                i = new InquiryDTO();
                i.setInquiryId(rs.getInt("inquiry_id"));
                i.setUserId(rs.getString("user_id"));
                i.setCategory(rs.getString("category"));
                i.setTitle(rs.getString("title"));
                i.setContent(rs.getString("content"));
                i.setAnswer(rs.getString("answer"));
                i.setStatus(rs.getString("status"));
                i.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return i;
    }

    public int insertInquiry(InquiryDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "INSERT INTO Inquiry (user_id, category, title, content, status, created_at) VALUES (?, ?, ?, ?, 'WAITING', NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getUserId());
            pstmt.setString(2, dto.getCategory());
            pstmt.setString(3, dto.getTitle());
            pstmt.setString(4, dto.getContent());
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    public int answerInquiry(int id, String answer) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "UPDATE Inquiry SET answer = ?, status = 'ANSWERED', answered_at = NOW() WHERE inquiry_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, answer);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }
}