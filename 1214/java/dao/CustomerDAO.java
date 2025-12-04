package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.NoticeDTO;
import dto.InquiryDTO;
import util.DBManager;

public class CustomerDAO {

    // --- [공지사항 관련 메서드들 (기존 유지)] ---
    public List<NoticeDTO> getNoticeList(String sort) {
        List<NoticeDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String orderBy = "reg_date DESC";
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
            pstmt = conn.prepareStatement("UPDATE Notice SET views = views + 1 WHERE notice_id = ?");
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            pstmt.close();

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

    // --- [1:1 문의 관련 메서드 (업데이트됨)] ---
    
    // 1. 목록 조회
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
                i.setContent(rs.getString("content")); // 내용 추가
                i.setAnswer(rs.getString("answer"));   // 답변 추가
                i.setStatus(rs.getString("status"));
                i.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(i);
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return list;
    }

    // 2. 상세 조회
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

    // 3. 문의 등록
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

    // 4. 답변 등록 (관리자용)
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

    // 5. [추가] 문의 수정
    public int updateInquiry(InquiryDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;
        try {
            conn = DBManager.getConnection();
            // 본인 글이면서, 답변 대기(WAITING) 상태일 때만 수정 가능
            String sql = "UPDATE Inquiry SET category=?, title=?, content=? WHERE inquiry_id=? AND user_id=? AND status='WAITING'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getCategory());
            pstmt.setString(2, dto.getTitle());
            pstmt.setString(3, dto.getContent());
            pstmt.setInt(4, dto.getInquiryId());
            pstmt.setString(5, dto.getUserId());
            result = pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return result;
    }

    // 6. [추가] 문의 삭제
    public int deleteInquiry(int id, String userId, boolean isAdmin) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;
        try {
            conn = DBManager.getConnection();
            String sql;
            if (isAdmin) {
                // 관리자는 무조건 삭제 가능
                sql = "DELETE FROM Inquiry WHERE inquiry_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
            } else {
                // 사용자는 본인 글만 삭제 가능
                sql = "DELETE FROM Inquiry WHERE inquiry_id=? AND user_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.setString(2, userId);
            }
            result = pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return result;
    }
}