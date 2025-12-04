<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.*, dto.InquiryDTO, java.text.SimpleDateFormat" %>
<%
    // Controller에서 데이터 받기
    List<InquiryDTO> inquiryList = (List<InquiryDTO>) request.getAttribute("inquiryList");
    if (inquiryList == null) inquiryList = new ArrayList<>();
    
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    boolean isAdmin = "true".equals(session.getAttribute("isAdmin"));
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>1:1 문의 목록</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap');
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background-color: #f9f9f9; color: #333;
        }
        
        .inquiry-container { max-width: 1000px;
        margin: 40px auto; padding: 30px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); min-height: 600px;
        }
        .inquiry-container h2 { font-size: 28px; font-weight: 700; text-align: center; margin-bottom: 40px;
        color: #333; }
        
        .inquiry-table { width: 100%;
        border-collapse: collapse; margin-bottom: 20px; }
        .inquiry-table th, .inquiry-table td { padding: 15px;
        text-align: center; border-bottom: 1px solid #eee; font-size: 15px; }
        .inquiry-table th { background-color: #f8f9fa;
        font-weight: 600; color: #555; border-top: 2px solid #333; }
        
        .inquiry-row { cursor: pointer;
        transition: background-color 0.2s; }
        .inquiry-row:hover { background-color: #f0f8ff;
        } 
        
        .inquiry-table td.title { text-align: left;
        padding-left: 20px; font-weight: 500; }
        
        .detail-row { display: none;
        background-color: #fafafa; border-bottom: 1px solid #ddd; }
        .detail-content { padding: 30px 40px;
        text-align: left; }
        
        .q-box { margin-bottom: 20px;
        }
        .q-mark { color: #ff9800; font-weight: bold; font-size: 18px; margin-right: 8px;
        }
        .q-text { white-space: pre-wrap; line-height: 1.6; color: #333;
        }
        
        .a-box { margin-top: 20px;
        padding: 20px; background-color: #fff; border: 1px solid #eee; border-radius: 8px;
        }
        .a-mark { color: #4caf50; font-weight: bold; font-size: 18px; margin-right: 8px;
        }
        .a-text { white-space: pre-wrap; line-height: 1.6; color: #333;
        }
        
        .status-badge { display: inline-block;
        padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
        .status-waiting { background-color: #f0f0f0;
        color: #888; border: 1px solid #ddd; }
        .status-answered { background-color: #e8f5e9; color: #4caf50;
        border: 1px solid #c8e6c9; }

        .write-btn-area { text-align: right; margin-top: 20px;
        }
        .btn-write { display: inline-block; padding: 12px 25px; background-color: #333; color: white;
        text-decoration: none; border-radius: 4px; font-weight: 500; }
        
        .admin-form textarea { width: 100%;
        height: 120px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; resize: vertical; font-family: inherit; margin-top: 10px; box-sizing: border-box;
        }
        .admin-form button { margin-top: 10px; padding: 8px 20px; background-color: #2c7be5; color: white;
        border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .admin-form button:hover { background-color: #1a68d1;
        }
        
        .no-data { text-align: center;
        padding: 50px; color: #888; font-size: 16px; }
    </style>
    
    <script>
        function toggleDetail(id) {
            var row = document.getElementById('detail-' + id);
            if (row.style.display === 'table-row') {
                row.style.display = 'none';
            } else {
                var allRows = document.getElementsByClassName('detail-row');
                for(var i=0; i<allRows.length; i++) {
                    allRows[i].style.display = 'none';
                }
                row.style.display = 'table-row';
            }
        }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="inquiry-container">
        <h2>1:1 문의</h2>
        
        <table class="inquiry-table">
            <colgroup>
                <col style="width: 8%;">
                <col style="width: 12%;">
                <col style="width: 15%;">
                <col style="width: auto;">
                <col style="width: 15%;">
                <% if (isAdmin) { %> <col style="width: 10%;"> <% } %>
            </colgroup>
           
            <thead>
                <tr>
                    <th>번호</th>
                    <th>상태</th>
                    <th>카테고리</th>
                    <th>제목</th>
                    <th>등록일</th>
                    <% if (isAdmin) { %> <th>작성자</th> <% } %>
                </tr>
            </thead>
            <tbody>
               
                <% if (inquiryList.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= isAdmin ? 6 : 5 %>" class="no-data">등록된 문의가 없습니다.</td>
                    </tr>
                <% } else { 
 
                    int idx = inquiryList.size();
                    for (InquiryDTO item : inquiryList) {
                        String status = item.getStatus();
                        String answer = item.getAnswer();
                        String content = item.getContent();
                        
                        String statusClass = "status-waiting";
                        String statusText = "답변대기";
                        if ("ANSWERED".equals(status)) {
                            statusClass = "status-answered";
                            statusText = "답변완료";
                        }
                %>
                    <tr class="inquiry-row" onclick="toggleDetail(<%= item.getInquiryId() %>)">
                        <td><%= idx-- %></td>
                        <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                        <td><%= item.getCategory() %></td>
                        <td class="title"><%= item.getTitle() %></td>
                        <td><%= sdf.format(item.getCreatedAt()) %></td>
                      
                        <% if (isAdmin) { %>
                            <td style="color:#888; font-size:13px;"><%= item.getUserId() %></td>
                        <% } %>
                    </tr>
                
                    <tr id="detail-<%= item.getInquiryId() %>" class="detail-row">
                        <td colspan="<%= isAdmin ? 6 : 5 %>">
                            <div class="detail-content">
            
                                <div class="q-box">
                                    <span class="q-mark">Q.</span>
                                    <span class="q-text"><%= (content != null) ? content.replace("\n", "<br>") : "" %></span>
                                </div>
                                
                                <% if (isAdmin) { %>
                                    <div style="margin-bottom: 10px; text-align: right;">
                                        <a href="admin_member_manage.jsp?keyword=<%= item.getUserId() %>" target="_blank" 
                                           style="color: red; font-size: 12px; margin-right: 15px; text-decoration: underline; font-weight: bold;">
                                            🚨 작성자(<%= item.getUserId() %>) 제재하러 가기
                                        </a>
                                        
                                        <button type="button" 
                                                onclick="if(confirm('정말 이 문의를 삭제하시겠습니까?\n(삭제 후에는 복구할 수 없습니다)')) location.href='customer?cmd=inquiryDelete&inquiry_id=<%= item.getInquiryId() %>'"
                                                style="padding: 6px 12px; background-color: #d9534f; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold;">
                                            🗑️ 문의 삭제
                                        </button>
                                    </div>

                                    <div class="a-box admin-form" style="background-color: #f1f8ff; border: 1px solid #cce5ff;">
                                        <span class="a-mark">A.</span> <b>관리자 답변 작성</b>
        
                                        <form action="customer" method="post">
                                            <input type="hidden" name="cmd" value="inquiryAnswer">
                                            <input type="hidden" name="inquiry_id" value="<%= item.getInquiryId() %>">
                                            
                                            <textarea name="answer" placeholder="답변 내용을 입력하세요."><%= (answer != null) ? answer : "" %></textarea>
                                            <div style="text-align:right;">
                                                <button type="submit"><%= (answer != null) ? "답변 수정" : "답변 등록" %></button>
                                            </div>
                                        </form>
                                    </div>
                                <% } else { %>
                                    <% if ("ANSWERED".equals(status) && answer != null) { %>
                                        <div class="a-box">
                                            <span class="a-mark">A.</span>
                                            <span style="font-weight:bold; color:#333;">중고모아 고객센터</span><br><br>
                                            <span class="a-text"><%= answer.replace("\n", "<br>") %></span>
                                        </div>
                                    <% } else { %>
                                        <div class="a-box" style="background-color:#f9f9f9; color:#999; text-align:center;">
                                            아직 답변이 등록되지 않았습니다.<br> 조금만 기다려주세요.
                                        </div>
                                    <% } %>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } } %>
            </tbody>
        </table>
        
        <div class="write-btn-area">
            <a href="inquiry_write_form.jsp" class="btn-write">문의하기</a>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>