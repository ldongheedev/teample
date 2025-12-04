package dto;

import java.sql.Timestamp;

public class ProductDTO {
    private int productId;
    private String userId;
    private String categoryId;
    private String productName;
    private int price;
    private String description;
    private String mainImageUrl;
    private boolean shippingIncluded;
    private boolean isDirectTrade;
    private boolean isSoldOut;
    private Timestamp createdAt;
    
    // 추가 정보 (조인용)
    private String sellerNickname;
    private String categoryName;

    // 기본 생성자
    public ProductDTO() {}

    // Getter & Setter
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getCategoryId() { return categoryId; }
    public void setCategoryId(String categoryId) { this.categoryId = categoryId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getMainImageUrl() { return mainImageUrl; }
    public void setMainImageUrl(String mainImageUrl) { this.mainImageUrl = mainImageUrl; }
    public boolean isShippingIncluded() { return shippingIncluded; }
    public void setShippingIncluded(boolean shippingIncluded) { this.shippingIncluded = shippingIncluded; }
    public boolean isDirectTrade() { return isDirectTrade; }
    public void setDirectTrade(boolean isDirectTrade) { this.isDirectTrade = isDirectTrade; }
    public boolean isSoldOut() { return isSoldOut; }
    public void setSoldOut(boolean isSoldOut) { this.isSoldOut = isSoldOut; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getSellerNickname() { return sellerNickname; }
    public void setSellerNickname(String sellerNickname) { this.sellerNickname = sellerNickname; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}