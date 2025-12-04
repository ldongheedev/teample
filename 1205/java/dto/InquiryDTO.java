package dto;
import java.sql.Timestamp;

public class InquiryDTO {
    private int inquiryId;
    private String userId;
    private String category;
    private String title;
    private String content;
    private String answer;
    private String status; // WAITING, ANSWERED
    private Timestamp createdAt;
    private Timestamp answeredAt;

    // Getter & Setter
    public int getInquiryId() { return inquiryId; }
    public void setInquiryId(int inquiryId) { this.inquiryId = inquiryId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getAnsweredAt() { return answeredAt; }
    public void setAnsweredAt(Timestamp answeredAt) { this.answeredAt = answeredAt; }
}