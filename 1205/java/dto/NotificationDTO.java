package dto;
import java.sql.Timestamp;

public class NotificationDTO {
    private int notiId;
    private String userId;
    private String type;     // INQUIRY, WARNING, DELETE, TRADE
    private String message;
    private String url;
    private boolean isRead;
    private Timestamp createdAt;

    public NotificationDTO() {}

    public int getNotiId() { return notiId; }
    public void setNotiId(int notiId) { this.notiId = notiId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    public boolean isRead() { return isRead; }
    public void setRead(boolean isRead) { this.isRead = isRead; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}