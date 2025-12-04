<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String isAdmin = (String) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin.equals("true")) {
        out.println("<script>alert('관리자 권한이 없습니다.'); location.href='main_page.jsp';</script>");
        return;
    }

    String cmd = request.getParameter("cmd");
    String memberId = request.getParameter("id");
    if (cmd == null || memberId == null) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String msg = "";
    
    // ✨ 알림 저장용 SQL 미리 준비
    String notiSql = "INSERT INTO Notification (user_id, type, message, url, created_at) VALUES (?, ?, ?, ?, NOW())";
    PreparedStatement notiPstmt = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false); // 트랜잭션 시작

        if ("warn".equals(cmd)) {
            // 1. 경고 횟수 증가
            String sqlUpdate = "UPDATE member SET warning_count = warning_count + 1 WHERE id = ?";
            pstmt = conn.prepareStatement(sqlUpdate);
            pstmt.setString(1, memberId);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. 누적 횟수 확인
            String sqlSelect = "SELECT warning_count FROM member WHERE id = ?";
            pstmt = conn.prepareStatement(sqlSelect);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            
            int warnings = 0;
            if (rs.next()) {
                warnings = rs.getInt("warning_count");
            }
            rs.close();
            pstmt.close();
            
            msg = "[" + memberId + "] 님에게 경고를 부여했습니다. (현재 누적: " + warnings + "회)";
            
            // ✨ [수정] 같은 conn 사용하여 알림 저장 (데드락 방지)
            notiPstmt = conn.prepareStatement(notiSql);
            notiPstmt.setString(1, memberId);
            notiPstmt.setString(2, "WARNING");
            notiPstmt.setString(3, "관리자로부터 경고를 받았습니다. (누적 " + warnings + "회)");
            notiPstmt.setString(4, null);
            notiPstmt.executeUpdate();
            notiPstmt.close();

            // 3. 자동 제재 로직
            if (warnings >= 10) {
                cmd = "delete"; // 아래 delete 로직 실행
                
                String[] tables = {"Wishlist", "TradeRequest", "TradeRequest", "Inquiry", "Product"};
                String[] cols = {"user_id", "buyer_id", "seller_id", "user_id", "user_id"};
                
                for(int i=0; i<tables.length; i++) {
                    pstmt = conn.prepareStatement("DELETE FROM " + tables[i] + " WHERE " + cols[i] + " = ?");
                    pstmt.setString(1, memberId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
                pstmt = conn.prepareStatement("DELETE FROM member WHERE id = ?");
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                
                msg = "[" + memberId + "] 님은 경고 10회 누적으로 '자동 영구 탈퇴' 처리되었습니다.";
                
            } else if (warnings == 5) {
                String sqlSuspend = "UPDATE member SET status = 'SUSPENDED', suspension_end_date = DATE_ADD(NOW(), INTERVAL 30 DAY) WHERE id = ?";
                pstmt = conn.prepareStatement(sqlSuspend);
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                msg += "\n⚠️ 경고 5회 누적으로 '30일 정지' 처리되었습니다.";
                
                // 정지 알림
                notiPstmt = conn.prepareStatement(notiSql);
                notiPstmt.setString(1, memberId);
                notiPstmt.setString(2, "WARNING");
                notiPstmt.setString(3, "경고 5회 누적으로 30일간 계정이 정지됩니다.");
                notiPstmt.setString(4, null);
                notiPstmt.executeUpdate();
                notiPstmt.close();

            } else if (warnings == 3) {
                String sqlSuspend = "UPDATE member SET status = 'SUSPENDED', suspension_end_date = DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE id = ?";
                pstmt = conn.prepareStatement(sqlSuspend);
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                msg += "\n⚠️ 경고 3회 누적으로 '7일 정지' 처리되었습니다.";
                
                // 정지 알림
                notiPstmt = conn.prepareStatement(notiSql);
                notiPstmt.setString(1, memberId);
                notiPstmt.setString(2, "WARNING");
                notiPstmt.setString(3, "경고 3회 누적으로 7일간 계정이 정지됩니다.");
                notiPstmt.setString(4, null);
                notiPstmt.executeUpdate();
                notiPstmt.close();
            }

        } 
        
        // ✨ 경고 차감
        if ("warn_cancel".equals(cmd)) {
            String sqlCheck = "SELECT warning_count FROM member WHERE id = ?";
            pstmt = conn.prepareStatement(sqlCheck);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            int currentWarnings = 0;
            if (rs.next()) {
                currentWarnings = rs.getInt("warning_count");
            }
            rs.close();
            pstmt.close();

            if (currentWarnings > 0) {
                String sqlUpdate = "UPDATE member SET warning_count = warning_count - 1 WHERE id = ?";
                pstmt = conn.prepareStatement(sqlUpdate);
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                msg = "[" + memberId + "] 님의 경고를 1회 차감했습니다. (현재 누적: " + (currentWarnings - 1) + "회)";
                
                // 차감 알림
                notiPstmt = conn.prepareStatement(notiSql);
                notiPstmt.setString(1, memberId);
                notiPstmt.setString(2, "WARNING");
                notiPstmt.setString(3, "관리자 조치로 경고가 1회 차감되었습니다.");
                notiPstmt.setString(4, null);
                notiPstmt.executeUpdate();
                notiPstmt.close();
                
            } else {
                msg = "경고 횟수가 0이라 차감할 수 없습니다.";
            }
        }

        // 강제 탈퇴
        if ("delete".equals(cmd)) {
             String checkSql = "SELECT id FROM member WHERE id = ?";
             pstmt = conn.prepareStatement(checkSql);
             pstmt.setString(1, memberId);
             rs = pstmt.executeQuery();
             if(rs.next()) {
                 rs.close();
                 pstmt.close();
                 
                 String[] tables = {"Wishlist", "TradeRequest", "TradeRequest", "Inquiry", "Product"};
                 String[] cols = {"user_id", "buyer_id", "seller_id", "user_id", "user_id"};
                 for(int i=0; i<tables.length; i++) {
                    pstmt = conn.prepareStatement("DELETE FROM " + tables[i] + " WHERE " + cols[i] + " = ?");
                    pstmt.setString(1, memberId);
                    pstmt.executeUpdate();
                    pstmt.close();
                 }
                 pstmt = conn.prepareStatement("DELETE FROM member WHERE id = ?");
                 pstmt.setString(1, memberId);
                 pstmt.executeUpdate();
                 msg = "[" + memberId + "] 님을 강제 탈퇴시켰습니다.";
             } else {
                 if(rs != null) rs.close();
                 if(pstmt != null) pstmt.close();
             }
        }
        
        // 정지 해제
        if ("activate".equals(cmd)) {
            String sql = "UPDATE member SET status = 'ACTIVE', suspension_end_date = NULL WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.executeUpdate();
            msg = "[" + memberId + "] 님의 정지를 해제했습니다.";
            
            // 해제 알림
            notiPstmt = conn.prepareStatement(notiSql);
            notiPstmt.setString(1, memberId);
            notiPstmt.setString(2, "WARNING");
            notiPstmt.setString(3, "관리자에 의해 계정 정지가 해제되었습니다.");
            notiPstmt.setString(4, null);
            notiPstmt.executeUpdate();
            notiPstmt.close();
        }

        conn.commit();
        session.setAttribute("toastMessage", msg);
        response.sendRedirect("admin_member_manage.jsp");
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        // 모든 리소스 정리
        if (notiPstmt != null) try { notiPstmt.close(); } catch(SQLException ex) {}
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch(SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if (rs != null) try { rs.close(); } catch(SQLException ex) {}
    }
%>