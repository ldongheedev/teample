package dao;

import java.sql.*;
import java.util.Date;
import dto.MemberDTO;
import util.DBManager;

public class MemberDAO {

    // 1. 로그인 체크 (정지 상태 자동 해제 로직 포함)
    public int loginCheck(String id, String pw) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT pw, status, suspension_end_date FROM member WHERE id = ?";

        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String dbPw = rs.getString("pw");
                String status = rs.getString("status");
                Timestamp suspendEnd = rs.getTimestamp("suspension_end_date");

                if (dbPw.equals(pw)) {
                    // 정지 상태 체크
                    if ("SUSPENDED".equals(status)) {
                        if (suspendEnd != null && new Date().after(suspendEnd)) {
                            // 정지 기간 만료 -> 해제 업데이트
                            releaseSuspension(id);
                            return 1; // 로그인 성공 (해제됨)
                        } else {
                            return -2; // 정지된 계정
                        }
                    }
                    return 1; // 로그인 성공
                } else {
                    return 0; // 비밀번호 불일치
                }
            }
            return -1; // 아이디 없음
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager.close(conn, pstmt, rs);
        }
        return -99; // DB 오류
    }

    // 정지 해제 메서드 (내부용)
    private void releaseSuspension(String id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "UPDATE member SET status = 'ACTIVE', suspension_end_date = NULL WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
    }

    // 2. 회원 정보 가져오기 (trade_addr 포함)
    public MemberDTO getMember(String id) {
        MemberDTO dto = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM member WHERE id = ?";

        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new MemberDTO();
                dto.setId(rs.getString("id"));
                dto.setPw(rs.getString("pw")); // 비밀번호 확인용
                dto.setNickname(rs.getString("nickname"));
                dto.setEmail(rs.getString("email"));
                dto.setPhone(rs.getString("phone"));
                dto.setAddrZip(rs.getString("addr_zip"));
                dto.setAddrBase(rs.getString("addr_base"));
                dto.setAddrDetail(rs.getString("addr_detail"));
                dto.setTradeAddr(rs.getString("trade_addr")); // 거래 주소
                dto.setIsAdmin(rs.getString("isAdmin"));
            }
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return dto;
    }

    // 3. 아이디 중복 체크
    public boolean isIdExist(String id) {
        boolean result = false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement("SELECT id FROM member WHERE id = ?");
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            if (rs.next()) result = true;
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, rs); }
        return result;
    }
    
    // 4. 회원 가입
    public int insertMember(MemberDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        // trade_addr 컬럼 추가
        String sql = "INSERT INTO member (id, pw, nickname, email, phone, addr_zip, addr_base, addr_detail, trade_addr, status, isAdmin, warning_count, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', 'false', 0, NOW())";
        try {
            conn = DBManager.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getId());
            pstmt.setString(2, dto.getPw());
            pstmt.setString(3, dto.getNickname());
            pstmt.setString(4, dto.getEmail());
            pstmt.setString(5, dto.getPhone());
            pstmt.setString(6, dto.getAddrZip());
            pstmt.setString(7, dto.getAddrBase());
            pstmt.setString(8, dto.getAddrDetail());
            pstmt.setString(9, dto.getTradeAddr()); // 거래 주소
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }

    // ✨ [추가된 부분] 5. 회원 정보 수정 (이게 없어서 에러가 났습니다!)
    public int updateMember(MemberDTO dto, boolean updatePw) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            StringBuilder sql = new StringBuilder("UPDATE member SET email=?, phone=?, addr_zip=?, addr_base=?, addr_detail=?, trade_addr=? ");
            if (updatePw) sql.append(", pw=? ");
            sql.append("WHERE id=?");
            
            pstmt = conn.prepareStatement(sql.toString());
            int i = 1;
            pstmt.setString(i++, dto.getEmail());
            pstmt.setString(i++, dto.getPhone());
            pstmt.setString(i++, dto.getAddrZip());
            pstmt.setString(i++, dto.getAddrBase());
            pstmt.setString(i++, dto.getAddrDetail());
            pstmt.setString(i++, dto.getTradeAddr());
            if (updatePw) pstmt.setString(i++, dto.getPw());
            pstmt.setString(i++, dto.getId());
            
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); } 
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }
}