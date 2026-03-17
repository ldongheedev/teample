package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 데이터베이스 연결을 관리하는 유틸리티 클래스
 * 환경설정에서 DB 정보를 읽어 연결을 생성
 */
public class DBConnection {
    
    /**
     * 데이터베이스 연결 생성
     * @return Connection 객체
     * @throws SQLException DB 연결 실패 시
     * @throws ClassNotFoundException 드라이버 없을 시
     */
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // application.properties에서 DB 설정 읽기
        String driver = ConfigLoader.getProperty("db.driver");
        String dbUrl = ConfigLoader.getProperty("db.url");
        String dbUsername = ConfigLoader.getProperty("db.username");
        String dbPassword = ConfigLoader.getProperty("db.password");
        
        // 드라이버 로드
        Class.forName(driver);
        
        // DB 연결 생성
        return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    }
    
    /**
     * 리소스 정리 헬퍼 메서드
     * @param rs ResultSet
     * @param pstmt PreparedStatement
     * @param conn Connection
     */
    public static void close(java.sql.ResultSet rs, java.sql.PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 리소스 정리 헬퍼 메서드 (ResultSet 제외)
     * @param pstmt PreparedStatement
     * @param conn Connection
     */
    public static void close(java.sql.PreparedStatement pstmt, Connection conn) {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 리소스 정리 헬퍼 메서드 (Connection만)
     * @param conn Connection
     */
    public static void close(Connection conn) {
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
