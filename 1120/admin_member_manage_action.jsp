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

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3308/jspdb", "jsp", "1234");
        conn.setAutoCommit(false);

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

            // 3. 자동 제재 로직
            if (warnings >= 10) {
                // 10회 -> 강제 탈퇴 (delete 로직 수행)
                cmd = "delete"; // 아래의 delete 블록으로 넘어가지는 않으므로 직접 호출 필요
                
                // 삭제 로직 (중복 방지를 위해 아래 로직과 동일하게 실행)
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
                // 5회 -> 30일 정지
                String sqlSuspend = "UPDATE member SET status = 'SUSPENDED', suspension_end_date = DATE_ADD(NOW(), INTERVAL 30 DAY) WHERE id = ?";
                pstmt = conn.prepareStatement(sqlSuspend);
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                msg += "\n⚠️ 경고 5회 누적으로 '30일 정지' 처리되었습니다.";

            } else if (warnings == 3) {
                // 3회 -> 7일 정지
                String sqlSuspend = "UPDATE member SET status = 'SUSPENDED', suspension_end_date = DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE id = ?";
                pstmt = conn.prepareStatement(sqlSuspend);
                pstmt.setString(1, memberId);
                pstmt.executeUpdate();
                msg += "\n⚠️ 경고 3회 누적으로 '7일 정지' 처리되었습니다.";
            }

        } 
        
        // "delete"는 위에서 10회 누적 시 실행될 수도 있고, 관리자가 버튼을 눌러서(cmd="delete") 실행될 수도 있음
        if ("delete".equals(cmd)) {
             // 이미 위에서 처리되지 않았는지 확인 (warn -> delete 흐름이 아닐 때만 실행)
             // 편의상 중복 실행되어도 삭제할 데이터가 없으면 괜찮으므로 그대로 실행하거나, 
             // warn 블록에서 처리가 끝났으면 건너뛰도록 설계해야 함.
             // 여기서는 관리자가 직접 '강제탈퇴' 버튼을 눌렀을 때의 로직
             
             // 이미 삭제된 회원인지 확인
             String checkSql = "SELECT id FROM member WHERE id = ?";
             pstmt = conn.prepareStatement(checkSql);
             pstmt.setString(1, memberId);
             rs = pstmt.executeQuery();
             if(rs.next()) {
                 rs.close(); pstmt.close();
                 
                 // 삭제 진행
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
                 // 이미 warn 블록에서 삭제되었을 수 있음 -> 메시지 유지
             }
        }
        
        if ("activate".equals(cmd)) {
            // 정지 해제
            String sql = "UPDATE member SET status = 'ACTIVE', suspension_end_date = NULL WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.executeUpdate();
            msg = "[" + memberId + "] 님의 정지를 해제했습니다.";
        }

        conn.commit();
        session.setAttribute("toastMessage", msg);
        response.sendRedirect("admin_member_manage.jsp");

    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch(SQLException ex) {}
        e.printStackTrace();
        out.println("<script>alert('오류 발생: " + e.getMessage().replace("'", "\\'") + "'); history.back();</script>");
    } finally {
        if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch(SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch(SQLException ex) {}
        if (rs != null) try { rs.close(); } catch(SQLException ex) {}
    }
%>