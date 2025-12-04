package dto;
import java.sql.Timestamp;

public class TradeDTO {
    private int tradeId;
    private int productId;
    private String buyerId;
    private String sellerId;
    private String status; // REQUESTED, ACCEPTED, REJECTED, COMPLETED
    private Timestamp requestedAt;
    private Timestamp acceptedAt;
    
    // 화면 출력용 (JOIN 데이터)
    private String productName;
    private String mainImageUrl;
    private String otherNickname; // 상대방 닉네임
    private String otherPhone;    // 상대방 전화번호

    public TradeDTO() {}

    // Getter & Setter
    public int getTradeId() { return tradeId; }
    public void setTradeId(int tradeId) { this.tradeId = tradeId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getBuyerId() { return buyerId; }
    public void setBuyerId(String buyerId) { this.buyerId = buyerId; }
    public String getSellerId() { return sellerId; }
    public void setSellerId(String sellerId) { this.sellerId = sellerId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }
    public Timestamp getAcceptedAt() { return acceptedAt; }
    public void setAcceptedAt(Timestamp acceptedAt) { this.acceptedAt = acceptedAt; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getMainImageUrl() { return mainImageUrl; }
    public void setMainImageUrl(String mainImageUrl) { this.mainImageUrl = mainImageUrl; }
    public String getOtherNickname() { return otherNickname; }
    public void setOtherNickname(String otherNickname) { this.otherNickname = otherNickname; }
    public String getOtherPhone() { return otherPhone; }
    public void setOtherPhone(String otherPhone) { this.otherPhone = otherPhone; }
}