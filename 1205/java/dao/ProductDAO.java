package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dto.ProductDTO;
import util.DBManager;

public class ProductDAO {

    // 1. 상품 등록 (INSERT)
    public int insertProduct(ProductDTO p, List<String> detailImages) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedKey = 0;

        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작

            // (1) 상품 정보 등록
            String sql = "INSERT INTO Product (user_id, category_id, product_name, price, description, main_image_url, shipping_included, is_direct_trade) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, p.getUserId());
            pstmt.setString(2, p.getCategoryId());
            pstmt.setString(3, p.getProductName());
            pstmt.setInt(4, p.getPrice());
            pstmt.setString(5, p.getDescription());
            pstmt.setString(6, p.getMainImageUrl());
            pstmt.setBoolean(7, p.isShippingIncluded());
            pstmt.setBoolean(8, p.isDirectTrade());
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) generatedKey = rs.getInt(1);
            pstmt.close();

            // (2) 상세 이미지 등록
            if (!detailImages.isEmpty()) {
                String imgSql = "INSERT INTO ProductImage (product_id, image_url, display_order) VALUES (?, ?, ?)";
                pstmt = conn.prepareStatement(imgSql);
                for (int i = 0; i < detailImages.size(); i++) {
                    pstmt.setInt(1, generatedKey);
                    pstmt.setString(2, detailImages.get(i));
                    pstmt.setInt(3, i + 1);
                    pstmt.executeUpdate();
                }
            }
            conn.commit(); // 성공 시 커밋
            return generatedKey;

        } catch (Exception e) {
            try { if(conn != null) conn.rollback(); } catch(SQLException ex) {}
            e.printStackTrace();
        } finally {
            DBManager.close(conn, pstmt, rs);
        }
        return 0;
    }

    // 2. 상품 삭제 (DELETE)
    public int deleteProduct(int productId, String userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            conn.setAutoCommit(false);

            // 자식 데이터 삭제
            String[] tables = {"TradeRequest", "Wishlist", "ProductImage"};
            for (String table : tables) {
                String delSql = "DELETE FROM " + table + " WHERE product_id = ?";
                pstmt = conn.prepareStatement(delSql);
                pstmt.setInt(1, productId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            // 부모 데이터(상품) 삭제
            String sql = "DELETE FROM Product WHERE product_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            pstmt.setString(2, userId);
            int result = pstmt.executeUpdate();

            conn.commit();
            return result;
        } catch (Exception e) {
            try { if(conn != null) conn.rollback(); } catch(SQLException ex) {}
            e.printStackTrace();
        } finally {
            DBManager.close(conn, pstmt, null);
        }
        return 0;
    }
    
    // 3. 상품 정보 가져오기 (수정 및 조회용)
    public ProductDTO getProduct(int productId) {
        ProductDTO p = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBManager.getConnection();
            String sql = "SELECT * FROM Product WHERE product_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();
            if(rs.next()) {
                p = new ProductDTO();
                p.setProductId(rs.getInt("product_id"));
                // ✨ [핵심 수정] 이 부분이 빠져있어서 에러가 났었습니다!
                p.setUserId(rs.getString("user_id")); 
                
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getInt("price"));
                p.setDescription(rs.getString("description"));
                p.setCategoryId(rs.getString("category_id"));
                p.setMainImageUrl(rs.getString("main_image_url"));
                p.setShippingIncluded(rs.getBoolean("shipping_included"));
                p.setDirectTrade(rs.getBoolean("is_direct_trade"));
                p.setSoldOut(rs.getBoolean("is_sold_out"));
            }
        } catch(Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, rs); }
        return p;
    }

    // 4. 상품 수정 (UPDATE)
    public int updateProduct(ProductDTO p, boolean updateMainImg) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBManager.getConnection();
            String sql = "UPDATE Product SET category_id=?, product_name=?, price=?, description=?, shipping_included=?, is_direct_trade=?, updated_at=NOW() ";
            if(updateMainImg) sql += ", main_image_url=? ";
            sql += "WHERE product_id=? AND user_id=?";
            
            pstmt = conn.prepareStatement(sql);
            int idx = 1;
            pstmt.setString(idx++, p.getCategoryId());
            pstmt.setString(idx++, p.getProductName());
            pstmt.setInt(idx++, p.getPrice());
            pstmt.setString(idx++, p.getDescription());
            pstmt.setBoolean(idx++, p.isShippingIncluded());
            pstmt.setBoolean(idx++, p.isDirectTrade());
            if(updateMainImg) pstmt.setString(idx++, p.getMainImageUrl());
            pstmt.setInt(idx++, p.getProductId());
            pstmt.setString(idx++, p.getUserId());
            
            return pstmt.executeUpdate();
        } catch(Exception e) { e.printStackTrace(); }
        finally { DBManager.close(conn, pstmt, null); }
        return 0;
    }
}