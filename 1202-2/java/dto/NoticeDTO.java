package dto;
import java.sql.Timestamp;

public class NoticeDTO {
    private int noticeId;
    private String title;
    private String content;
    private String writerId;
    private Timestamp regDate;
    private int views;

    // Getter & Setter
    public int getNoticeId() { return noticeId; }
    public void setNoticeId(int noticeId) { this.noticeId = noticeId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getWriterId() { return writerId; }
    public void setWriterId(String writerId) { this.writerId = writerId; }
    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }
}