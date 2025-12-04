package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.NoticeDTO;
import dto.InquiryDTO;
import util.DBManager;

public class CustomerDAO {

    // --- [공지사항 관리] --- (기존과 동일)
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

    // --- [1:1 문의 관리] --- (기존과 동일)
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

    // ✨ [디버깅] 관리자 답변 등록 + 알림 발송 기능
    public int answerInquiry(int id, String answer) {
        System.out.println("====== [DEBUG] answerInquiry 시작. ID: " + id + " ======");
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작

            // (1) 문의글 작성자 ID 조회
            String writerId = null;
            String inqTitle = "";
            pstmt = conn.prepareStatement("SELECT user_id, title FROM Inquiry WHERE inquiry_id = ?");
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            if(rs.next()) {
                writerId = rs.getString("user_id");
                inqTitle = rs.getString("title");
                System.out.println("[DEBUG] 작성자 찾음: " + writerId + ", 제목: " + inqTitle);
            } else {
                System.out.println("[DEBUG] ⚠️ 작성자를 찾을 수 없음 (Inquiry ID 불일치?)");
            }
            pstmt.close();

            // (2) 답변 내용 업데이트
            String sql = "UPDATE Inquiry SET answer = ?, status = 'ANSWERED', answered_at = NOW() WHERE inquiry_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, answer);
            pstmt.setInt(2, id);
            int result = pstmt.executeUpdate();
            System.out.println("[DEBUG] 답변 업데이트 결과(result): " + result);
            
            // (3) 알림(Notification) 테이블에 추가
            if(result > 0 && writerId != null) {
                if(inqTitle.length() > 10) inqTitle = inqTitle.substring(0, 10) + "...";
                
                String message = "'" + inqTitle + "' 문의에 답변이 등록되었습니다.";
                String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, 'INQUIRY', ?, 'customer?cmd=inquiryList', NOW())";
                
                pstmt.close();
                pstmt = conn.prepareStatement(notiSql);
                pstmt.setString(1, writerId);
                pstmt.setString(2, message);
                int notiResult = pstmt.executeUpdate();
                System.out.println("[DEBUG] 알림 INSERT 결과: " + notiResult + " (User: " + writerId + ")");
            } else {
                System.out.println("[DEBUG] ⚠️ 알림 저장 스킵됨 (result<=0 or writerId null)");
            }

            conn.commit(); // 커밋
            System.out.println("====== [DEBUG] 트랜잭션 커밋 완료 ======");
            return result;
        } catch (Exception e) {
            try { if(conn!=null) conn.rollback(); } catch(SQLException ex){}
            e.printStackTrace();
            System.out.println("[DEBUG] ❌ 에러 발생: " + e.getMessage());
        } finally {
            DBManager.close(conn, pstmt, rs);
        }
        return 0;
    }

    // 9. 문의 삭제 (관리자용)
    public int deleteInquiry(int inquiryId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "DELETE FROM Inquiry WHERE inquiry_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, inquiryId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager.close(conn, pstmt, null);
        }
        return 0;
    }
}