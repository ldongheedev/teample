<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. 현재 사용자의 세션을 종료(무효화)시킵니다.
    //    session.setAttribute()로 저장했던 "userId", "userName" 등이 모두 사라집니다.
    session.invalidate();

    // 2. 세션 종료 후, main_page.jsp로 사용자를 즉시 이동시킵니다.
    response.sendRedirect("main_page.jsp");
%>