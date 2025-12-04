package dto;
import java.sql.Timestamp;

public class MemberDTO {
    private String id;
    private String pw;
    private String nickname;
    private String email;
    private String phone;
    private String addrZip;
    private String addrBase;
    private String addrDetail;
    private String tradeAddr; // ✨ [추가] 거래 희망 장소
    private String status;
    private String isAdmin;
    private int warningCount;
    private Timestamp createdAt;
    private Timestamp suspensionEndDate;

    public MemberDTO() {}

    // Getter & Setter
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getPw() { return pw; }
    public void setPw(String pw) { this.pw = pw; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAddrZip() { return addrZip; }
    public void setAddrZip(String addrZip) { this.addrZip = addrZip; }
    public String getAddrBase() { return addrBase; }
    public void setAddrBase(String addrBase) { this.addrBase = addrBase; }
    public String getAddrDetail() { return addrDetail; }
    public void setAddrDetail(String addrDetail) { this.addrDetail = addrDetail; }
    // ✨ [추가] Getter/Setter
    public String getTradeAddr() { return tradeAddr; }
    public void setTradeAddr(String tradeAddr) { this.tradeAddr = tradeAddr; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getIsAdmin() { return isAdmin; }
    public void setIsAdmin(String isAdmin) { this.isAdmin = isAdmin; }
    public int getWarningCount() { return warningCount; }
    public void setWarningCount(int warningCount) { this.warningCount = warningCount; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getSuspensionEndDate() { return suspensionEndDate; }
    public void setSuspensionEndDate(Timestamp suspensionEndDate) { this.suspensionEndDate = suspensionEndDate; }
}