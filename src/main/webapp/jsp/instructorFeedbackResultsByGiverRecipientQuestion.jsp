<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib tagdir="/WEB-INF/tags/instructor/results" prefix="r" %>
<%@ taglib tagdir="/WEB-INF/tags/shared" prefix="shared" %>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.HashSet"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Collections"%>
<%@ page import="teammates.common.util.Const"%>
<%@ page import="teammates.common.util.FieldValidator"%>
<%@ page import="teammates.common.datatransfer.FeedbackParticipantType"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackResponseCommentAttributes"%>
<%@ page import="teammates.common.datatransfer.FeedbackSessionResponseStatus" %>
<%@ page import="teammates.ui.controller.InstructorFeedbackResultsPageData"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionDetails"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionAttributes"%>
<%@ page import="teammates.ui.template.InstructorResultsModerationButton" %>
<%@ page import="teammates.ui.template.InstructorResultsGRQResponse" %>
<%@ page import="teammates.ui.template.GRQNoResponseRow" %>
<%@ page import="teammates.ui.template.FeedbackResponseComment" %>
<%@ page import="javax.servlet.jsp.jstl.core.LoopTagStatus" %>
<%
    InstructorFeedbackResultsPageData data = (InstructorFeedbackResultsPageData) request.getAttribute("data");
    FieldValidator validator = new FieldValidator();
    boolean showAll = data.bundle.isComplete;
    boolean shouldCollapsed = data.bundle.responses.size() > 500;
    boolean groupByTeamEnabled = (data.groupByTeam == null || !data.groupByTeam.equals("on")) ? false : true;
%>
<!DOCTYPE html>
<html>
<head>
    <title>TEAMMATES - Feedback Session Results</title>

    <link rel="shortcut icon" href="/favicon.png" />

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link type="text/css" href="/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    <link type="text/css" href="/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
    <link type="text/css" href="/stylesheets/teammatesCommon.css" rel="stylesheet"/>

    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <script type="text/javascript" src="/js/googleAnalytics.js"></script>
    <script type="text/javascript" src="<%= data.getjQueryFilePath() %>"></script>
    <script type="text/javascript" src="<%= data.getjQueryUiFilePath() %>"></script>
    <script type="text/javascript" src="/js/common.js"></script>
    <script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
    
    <jsp:include page="../enableJS.jsp"></jsp:include>

    <script type="text/javascript" src="/js/instructor.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResults.js"></script>
    <script type="text/javascript" src="/js/feedbackResponseComments.js"></script>
    <script type="text/javascript" src="/js/additionalQuestionInfo.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResultsAjaxByGRQ.js"></script>
    <script type="text/javascript" src="/js/instructorFeedbackResultsAjaxResponseRate.js"></script>
</head>

<body>
    <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_HEADER%>" />

        <div class="container" id="mainContent">
            <div id="topOfPage"></div>
            <h1>Session Results</h1>
            <br>
            <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_FEEDBACK_RESULTS_TOP%>" />
            <br>

            <%-- use this when the rest is tidied up
            <c:choose>
                <c:when test="${not data.bundle.complete}">
                </c:when>
                <c:otherwise>
                </c:otherwise>
            </c:choose>
            --%>
            <%
                if(!showAll) {
            %>
                <c:set var="EXCEEDING_RESPONSES_ERROR_MESSAGE"><%=InstructorFeedbackResultsPageData.EXCEEDING_RESPONSES_ERROR_MESSAGE%></c:set>
                <r:ajaxSectionPanel data="${data}"
                                    EXCEEDING_RESPONSES_ERROR_MESSAGE="${EXCEEDING_RESPONSES_ERROR_MESSAGE}" />
            <%
                } else {
            %>
                <%
                    String currentTeam = null;
                    boolean newTeam = false;
                    String currentSection = null;
                    boolean newSection = false;
                    int sectionIndex = -1;
                    int teamIndex = -1;
                    Set<String> teamMembersEmail = new HashSet<String>(); 
                    Set<String> teamMembersWithResponses = new HashSet<String>();
                    
                    Map<String, Map<String, List<FeedbackResponseAttributes>>> allResponses = data.bundle.getResponsesSortedByGiver(groupByTeamEnabled);
                    Map<String, FeedbackQuestionAttributes> questions = data.bundle.questions;

                    int giverIndex = data.startIndex;
                    
                    Set<String> teamsInSection = new HashSet<String>();
                    Set<String> givingTeams = new HashSet<String>();
                    
                    Set<String> sectionsInCourse = data.bundle.rosterSectionTeamNameTable.keySet();
                    Set<String> givingSections = new HashSet<String>();
                    
                    
                    for (Map.Entry<String, Map<String, List<FeedbackResponseAttributes>>> responsesFromGiver : allResponses.entrySet()) {
                %>
                    <%
                        giverIndex++;
                        pageContext.setAttribute("giverIndex", giverIndex);

                        Map<String, List<FeedbackResponseAttributes> > giverData = responsesFromGiver.getValue();
                        Object[] giverDataArray =  giverData.keySet().toArray();
                        FeedbackResponseAttributes firstResponse = giverData.get(giverDataArray[0]).get(0);
                        // giverEmail can be in the format "[student@example.com]'s Team"
                        String targetEmail = firstResponse.giverEmail.replace(Const.TEAM_OF_EMAIL_OWNER,"");
                        boolean isGiverVisible = data.bundle.isGiverVisible(firstResponse);
                    %>
                    <%
                        // if change in currentTeam
                        if (currentTeam != null && !(data.bundle.getTeamNameForEmail(targetEmail).isEmpty()
                                                     ? currentTeam.equals(data.bundle.getNameForEmail(targetEmail))
                                                     : currentTeam.equals(data.bundle.getTeamNameForEmail(targetEmail)))) {
                    %>
                        <%
                            currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                            if (currentTeam.isEmpty()) {
                                currentTeam = data.bundle.getNameForEmail(targetEmail);
                            }
                            newTeam = true;
                            // print out the "missing response" rows for the previous team
                            Set<String> teamMembersWithoutReceivingResponses = teamMembersEmail;
        
                            teamMembersWithoutReceivingResponses.removeAll(teamMembersWithResponses);
                            List<String> teamMembersWithNoResponses = new ArrayList<String>(teamMembersWithoutReceivingResponses);
                            Collections.sort(teamMembersWithNoResponses);
                            
                            for (String email : teamMembersWithNoResponses) {
                        %>
                            <% 
                                boolean isAllowedToModerate = data.instructor.isAllowedForPrivilege(
                                        data.bundle.getSectionFromRoster(email), data.feedbackSessionName,
                                        Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                                InstructorResultsModerationButton moderationButton = new InstructorResultsModerationButton(
                                        !isAllowedToModerate, "btn btn-default btn-xs", email, data.courseId, data.feedbackSessionName,
                                        null, "Moderate Responses");
                                
                                String profilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, email).isEmpty()
                                                        ? data.getProfilePictureLink(email) : null;
                                
                                GRQNoResponseRow responseHeader = new GRQNoResponseRow(
                                        email, data.bundle.getFullNameFromRoster(email),
                                        profilePicture, moderationButton);
                                pageContext.setAttribute("responseHeader", responseHeader);
                            %>
                            <r:grqResponse response="${responseHeader}" isCollapsed="${data.shouldCollapsed}" />
                        <%
                            }
                        %>
                        <%
                            if (groupByTeamEnabled) {
                        %>
                            </div>
                        <%
                            }
                        %>
                    <%
                        }
                    %>

                    <%
                        if (currentSection != null && !firstResponse.giverSection.equals(currentSection)) {
                    %>
                        <%
                            currentSection = firstResponse.giverSection;
                            newSection = true;
                        %>
                    <%
                        }
                    %>

                    <%
                        if (currentSection == null || newSection) {
                    %>
                        <%
                            currentSection = firstResponse.giverSection;
                            newSection = false;
                            sectionIndex++;
                            
                            givingSections.add(currentSection);
                            teamsInSection = data.bundle.getTeamsInSectionFromRoster(currentSection);
                            givingTeams = new HashSet<String>();
                        %>
                        <div class="panel panel-success">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-sm-9 panel-heading-text">
                                        <strong><%=currentSection.equals("None")? "Not in a section" : currentSection%></strong>                        
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="pull-right">
                                            <a class="btn btn-success btn-xs" id="collapse-panels-button-section-<%=sectionIndex%>" data-toggle="tooltip" title='Collapse or expand all <%=groupByTeamEnabled == true ? "team" : "student"%> panels. You can also click on the panel heading to toggle each one individually.'>
                                                <%=shouldCollapsed ? "Expand " : "Collapse "%> <%=groupByTeamEnabled == true ? "Teams" : "Students"%>
                                            </a>
                                            &nbsp;
                                            <span class="glyphicon glyphicon-chevron-up"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="panel-collapse collapse in">
                                <div class="panel-body" id="sectionBody-<%=sectionIndex%>">
                    <%
                        }
                    %>

                    <%
                        if(currentTeam==null || newTeam) {
                    %>
                        <%
                            currentTeam = data.bundle.getTeamNameForEmail(targetEmail);
                            if (currentTeam.isEmpty()) {
                                currentTeam = data.bundle.getNameForEmail(targetEmail);
                            }
                            
                            teamMembersWithResponses = new HashSet<String>();                                
                            teamMembersEmail = data.bundle.getTeamMembersFromRoster(currentTeam);
                            
                            teamIndex++;
                            newTeam = false;
                            
                            givingTeams.add(currentTeam);
                            
                            if (groupByTeamEnabled) {
                        %>
                            <div class="panel panel-warning">
                                <div class="panel-heading">
                                    <div class="row">
                                        <div class="col-sm-9 panel-heading-text">
                                            <strong><%=currentTeam%></strong>                     
                                        </div>
                                        <div class="col-sm-3">
                                            <div class="pull-right">
                                                <a class="btn btn-warning btn-xs" id="collapse-panels-button-team-<%=teamIndex%>" data-toggle="tooltip" title="Collapse or expand all student panels. You can also click on the panel heading to toggle each one individually.">
                                                    <%=shouldCollapsed ? "Expand " : "Collapse "%> Students
                                                </a>
                                                &nbsp;
                                                <span class='glyphicon <%=!shouldCollapsed ? "glyphicon-chevron-up" : "glyphicon-chevron-down"%>'></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class='panel-collapse collapse <%=shouldCollapsed ? "" : "in"%>'>
                                <div class="panel-body background-color-warning">
                        <%
                            }
                        %>
                    <%
                        }
                    %>

                    <%
                        teamMembersWithResponses.add(targetEmail);
                        
                        String giverEmail = firstResponse.giverEmail;
                        pageContext.setAttribute("giverEmail", giverEmail);
                        pageContext.setAttribute("giverName", responsesFromGiver.getKey());
                        String giverProfilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, targetEmail).isEmpty()
                                ? data.getProfilePictureLink(targetEmail) : null;
                        pageContext.setAttribute("giverProfilePicture", giverProfilePicture);
                        
                        boolean isAllowedToModerate = data.instructor.isAllowedForPrivilege(
                                data.bundle.getSectionFromRoster(targetEmail), data.feedbackSessionName,
                                Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                        pageContext.setAttribute("isGiverVisibleToCurrentUser", isGiverVisible
                                && data.bundle.isParticipantIdentifierStudent(targetEmail));
                        pageContext.setAttribute("isGiverAnonymous", giverEmail.contains("@@"));
                        pageContext.setAttribute("class", "link-in-dark-bg");
                    %>
                            
            <div class="panel panel-primary">
                <div class="panel-heading">
                    From:
                    <div class="inline panel-heading-text<c:if test="${not empty giverProfilePicture}"> middlealign profile-pic-icon-hover" data-link="${giverProfilePicture}</c:if>">
                        <strong>${giverName}</strong>
                        <c:if test="${not empty giverProfilePicture}">
                            <img src="" alt="No Image Given" class="hidden profile-pic-icon-hidden">
                        </c:if>
                        <c:if test="${not isGiverAnonymous}">
                            <a href="mailTo:${giverEmail}"<c:if test="${not empty class}"> class="${class}"</c:if>>[${giverEmail}]</a>
                        </c:if>
                    </div>
                    <div class="pull-right">
                        <c:if test="${isGiverVisibleToCurrentUser}">
                            <%
                                InstructorResultsModerationButton moderationButton = new InstructorResultsModerationButton(
                                        !isAllowedToModerate, "btn btn-primary btn-xs", targetEmail, data.courseId, data.feedbackSessionName,
                                        null, "Moderate Responses");
                                pageContext.setAttribute("moderationButton", moderationButton);
                            %>
                            <r:moderationsButton moderationButton="${moderationButton}" />
                            &nbsp;
                        </c:if>
                        <div class="display-icon" style="display:inline;">
                            <span class="glyphicon pull-right${data.shouldCollapsed ? ' glyphicon-chevron-down' : ' glyphicon-chevron-up'}"></span>
                        </div>
                    </div>
                </div>
                <div class="panel-collapse collapse<c:if test="${not data.shouldCollapsed}"> in</c:if>">
                <div class="panel-body">
                    <%
                        pageContext.setAttribute("responsesFromGiver", responsesFromGiver.getValue().entrySet());
                    %>
                    <c:forEach items="${responsesFromGiver}" var="responses" varStatus="recipientIndex">
                        <%
                            @SuppressWarnings("unchecked")
                            Map.Entry<String, List<FeedbackResponseAttributes>> responsesFromGiverToRecipient =
                                    (Map.Entry<String, List<FeedbackResponseAttributes>>)
                                            pageContext.getAttribute("responses");
                            pageContext.setAttribute("recipientName", responsesFromGiverToRecipient.getKey());    
                            
                            String recipientEmail = responsesFromGiverToRecipient.getValue().get(0).recipientEmail;
                            String recipientProfilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, recipientEmail).isEmpty()
                                    ? data.getProfilePictureLink(recipientEmail) : null;
                            pageContext.setAttribute("recipientProfilePicture", recipientProfilePicture);
                            
                            List<InstructorResultsGRQResponse> responses = new ArrayList<InstructorResultsGRQResponse>();
                            
                            LoopTagStatus recipientLoopTag = (LoopTagStatus) pageContext.getAttribute("recipientIndex");
                            int recipientIndex = recipientLoopTag.getCount();
                            
                            for (FeedbackResponseAttributes singleResponse : responsesFromGiverToRecipient.getValue()) {
                            	FeedbackQuestionAttributes question = questions.get(singleResponse.feedbackQuestionId);
                                FeedbackQuestionDetails questionDetails = question.getQuestionDetails();
                                String questionHtml = InstructorFeedbackResultsPageData.sanitizeForHtml(questionDetails.questionText)
                                        + questionDetails.getQuestionAdditionalInfoHtml(question.questionNumber,
                                                "giver-" + giverIndex + "-recipient-" + recipientIndex);
                                String answerHtml = data.bundle.getResponseAnswerHtml(singleResponse, question);
                                boolean allowedToSubmitSessionInSections =
                                        data.instructor.isAllowedForPrivilege(
                                                singleResponse.giverSection, singleResponse.feedbackSessionName,
                                                Const.ParamsNames.INSTRUCTOR_PERMISSION_SUBMIT_SESSION_IN_SECTIONS)
                                        && data.instructor.isAllowedForPrivilege(
                                                  singleResponse.recipientSection, singleResponse.feedbackSessionName,
                                                  Const.ParamsNames.INSTRUCTOR_PERMISSION_SUBMIT_SESSION_IN_SECTIONS);
                                
                                List<FeedbackResponseComment> comments = new ArrayList<FeedbackResponseComment>();
                                
                                List<FeedbackResponseCommentAttributes> frcAttributesList = data.bundle.responseComments.get(singleResponse.getId());
                                if (frcAttributesList != null) {
                                    for (FeedbackResponseCommentAttributes frcAttributes : frcAttributesList) {
                                        boolean isInstructorGiver = data.instructor.email.equals(frcAttributes.giverEmail);
                                        boolean isInstructorWithPrivilegesToModify =
                                                data.instructor.isAllowedForPrivilege(
                                                        singleResponse.giverSection, singleResponse.feedbackSessionName,
                                                        Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS)
                                                && data.instructor.isAllowedForPrivilege(
                                                           singleResponse.recipientSection, singleResponse.feedbackSessionName,
                                                           Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                                        boolean isInstructorAllowedToModify = isInstructorGiver || isInstructorWithPrivilegesToModify;
                                        
                                        boolean isResponseVisibleToRecipient =
                                                question.recipientType != FeedbackParticipantType.SELF
                                                && question.recipientType != FeedbackParticipantType.NONE
                                                && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER);
                                        
                                        boolean isResponseVisibleToGiverTeam =
                                                question.giverType != FeedbackParticipantType.INSTRUCTORS
                                                && question.giverType != FeedbackParticipantType.SELF
                                                && question.isResponseVisibleTo(FeedbackParticipantType.OWN_TEAM_MEMBERS);
                                        
                                        boolean isResponseVisibleToRecipientTeam =
                                                question.recipientType != FeedbackParticipantType.INSTRUCTORS
                                                && question.recipientType != FeedbackParticipantType.SELF
                                                && question.recipientType != FeedbackParticipantType.NONE
                                                && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER_TEAM_MEMBERS);
                                        
                                        boolean isResponseVisibleToStudents =
                                                question.isResponseVisibleTo(FeedbackParticipantType.STUDENTS);
                                        
                                        boolean isResponseVisibleToInstructors =
                                                question.isResponseVisibleTo(FeedbackParticipantType.INSTRUCTORS);
                                    
                                        FeedbackResponseComment frc = new FeedbackResponseComment(frcAttributes, frcAttributes.giverEmail,
                                                responsesFromGiver.getKey(), responsesFromGiverToRecipient.getKey(),
                                                data.getResponseCommentVisibilityString(frcAttributes, question),
                                                data.getResponseCommentGiverNameVisibilityString(frcAttributes, question),
                                                isResponseVisibleToRecipient, isResponseVisibleToGiverTeam, isResponseVisibleToRecipientTeam,
                                                isResponseVisibleToStudents, isResponseVisibleToInstructors,
                                                true, isInstructorAllowedToModify, isInstructorAllowedToModify);
                                    
                                        comments.add(frc);
                                    }
                                }
                                
                                String responseCommentVisibility = data.getResponseCommentVisibilityString(question);
                                String responseCommentGiverNameVisibility = data.getResponseCommentGiverNameVisibilityString(question);
                                
                                InstructorResultsGRQResponse grqResponse = new InstructorResultsGRQResponse(
                                        question.getId(), singleResponse.getId(),
                                        question.questionNumber, questionHtml, answerHtml, allowedToSubmitSessionInSections,
                                        comments, responseCommentVisibility, responseCommentGiverNameVisibility);
                                grqResponse.setQuestion(question); // to be removed
                                responses.add(grqResponse);
                            }
                            
                            pageContext.setAttribute("responsesFromGiverToRecipient", responses);
                        %>
                        <c:set var="isFirstResponse" value="${recipientIndex.index == 0}" />
                        <div class="row<c:if test="${not isFirstResponse}"> border-top-gray</c:if>">
                            <div class="col-md-2">
                                <div class="col-md-12">
                                    To:
                                    <c:choose>
                                        <c:when test="${empty recipientProfilePicture}">
                                            <strong>${recipientName}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="middlealign profile-pic-icon-hover inline-block" data-link="${recipientProfilePicture}">
                                                <strong>${recipientName}</strong>
                                                <img src="" alt="No Image Given" class="hidden profile-pic-icon-hidden">
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="col-md-12 text-muted small"><br>
                                    From:
                                    <c:choose>
                                        <c:when test="${empty giverProfilePicture}">
                                            ${giverName}
                                        </c:when>
                                        <c:otherwise>
                                            <div class="middlealign profile-pic-icon-hover inline-block" data-link="${giverProfilePicture}">
                                                ${giverName}
                                                <img src="" alt="No Image Given" class="hidden profile-pic-icon-hidden">
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="col-md-10">
                                <c:forEach items="${responsesFromGiverToRecipient}" var="response" varStatus="questionIndex">
                                    <div class="panel panel-info">
                                        <!--Note: When an element has class text-preserve-space, do not insert and HTML spaces-->
                                        <div class="panel-heading">
                                            Question ${response.questionNumber}:
                                            <span class="text-preserve-space">${response.questionHtml}</span>
                                        </div>
                                        <div class="panel-body">
                                            <div style="clear:both; overflow: hidden">
                                                <!--Note: When an element has class text-preserve-space, do not insert and HTML spaces-->
                                                <div class="pull-left text-preserve-space">${response.answerHtml}</div>
                                                <button type="button" class="btn btn-default btn-xs icon-button pull-right" id="button_add_comment" 
                                                    onclick="showResponseCommentAddForm(${recipientIndex.count},${giverIndex},${questionIndex.count})"
                                                    data-toggle="tooltip" data-placement="top" title="<%=Const.Tooltips.COMMENT_ADD%>"
                                                    <c:if test="${not response.allowedToSubmitSessionInSections}">disabled="disabled"</c:if>>
                                                    <span class="glyphicon glyphicon-comment glyphicon-primary"></span>
                                                </button>
                                            </div>
                                            <ul class="list-group" id="responseCommentTable-${recipientIndex.count}-${giverIndex}-${questionIndex.count}"
                                                style="${empty response.comments ? 'display:none' : 'margin-top:15px;'}">
                                                <c:forEach items="${response.comments}" var="frc" varStatus="i">
                                                    <shared:feedbackResponseComment frc="${frc}"
                                                                                    firstIndex="${recipientIndex.count}"
                                                                                    secondIndex="${giverIndex}"
                                                                                    thirdIndex="${questionIndex.count}"
                                                                                    frcIndex="${i.count}" />
                                                </c:forEach>
                                                <!-- frComment Add form -->
                                                <%
                                                    FeedbackQuestionAttributes question = ((InstructorResultsGRQResponse) pageContext.getAttribute("response")).getQuestion();
                                                %>
                                                <li class="list-group-item list-group-item-warning" id="showResponseCommentAddForm-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}" style="display:none;">
                                                    <form class="responseCommentAddForm">
                                                        <div class="form-group">
                                                            <div class="form-group form-inline">
                                                                <div class="form-group text-muted">
                                                                    <p>
                                                                        Giver: <%=responsesFromGiver.getKey()%><br>
                                                                        Recipient: <%=responsesFromGiverToRecipient.getKey()%>
                                                                    </p>
                                                                    You may change comment's visibility using the visibility options on the right hand side.
                                                                </div>
                                                                <a id="frComment-visibility-options-trigger-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}"
                                                                    class="btn btn-sm btn-info pull-right" onclick="toggleVisibilityEditForm(${recipientIndex.count},<%=giverIndex%>,${questionIndex.count})">
                                                                    <span class="glyphicon glyphicon-eye-close"></span>
                                                                    Show Visibility Options
                                                                </a>
                                                            </div>
                                                            <div id="visibility-options-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}" class="panel panel-default"
                                                                style="display: none;">
                                                                <div class="panel-heading">Visibility Options</div>
                                                                <table class="table text-center" style="color:#000;"
                                                                    style="background: #fff;">
                                                                    <tbody>
                                                                        <tr>
                                                                            <th class="text-center">User/Group</th>
                                                                            <th class="text-center">Can see your comment</th>
                                                                            <th class="text-center">Can see your name</th>
                                                                        </tr>
                                                                        <tr id="response-giver-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                            <td class="text-left">
                                                                                <div data-toggle="tooltip"
                                                                                    data-placement="top" title=""
                                                                                    data-original-title="Control what response giver can view">
                                                                                    Response Giver</div>
                                                                            </td>
                                                                            <td>
                                                                                <input class="visibilityCheckbox answerCheckbox centered"
                                                                                    name="receiverLeaderCheckbox"
                                                                                    type="checkbox" value="<%=FeedbackParticipantType.GIVER%>"
                                                                                    <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.GIVER)?"checked=\"checked\"":""%>>
                                                                            </td>
                                                                            <td>
                                                                                <input class="visibilityCheckbox giverCheckbox"
                                                                                    type="checkbox" value="<%=FeedbackParticipantType.GIVER%>"
                                                                                    <%=data.isResponseCommentGiverNameVisibleTo( question, FeedbackParticipantType.GIVER)?"checked=\"checked\"":""%>>
                                                                            </td>
                                                                        </tr>
                                                                        <%
                                                                            if (question.recipientType != FeedbackParticipantType.SELF
                                                                                && question.recipientType != FeedbackParticipantType.NONE
                                                                                && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER)) {
                                                                        %>
                                                                            <tr id="response-recipient-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                                <td class="text-left">
                                                                                    <div data-toggle="tooltip"
                                                                                        data-placement="top" title=""
                                                                                        data-original-title="Control what response recipient(s) can view">
                                                                                        Response Recipient(s)</div>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox answerCheckbox centered"
                                                                                        name="receiverLeaderCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.RECEIVER%>"
                                                                                        <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.RECEIVER)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox giverCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.RECEIVER%>"
                                                                                        <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.RECEIVER)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            }
                                                                        %>
                                                                        <%
                                                                            if (question.giverType != FeedbackParticipantType.INSTRUCTORS
                                                                                && question.giverType != FeedbackParticipantType.SELF
                                                                                && question.isResponseVisibleTo(FeedbackParticipantType.OWN_TEAM_MEMBERS)) {
                                                                        %>
                                                                            <tr id="response-giver-team-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                                <td class="text-left">
                                                                                    <div data-toggle="tooltip"
                                                                                        data-placement="top" title=""
                                                                                        data-original-title="Control what team members of response giver can view">
                                                                                        Response Giver's Team Members</div>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox answerCheckbox"
                                                                                        type="checkbox"
                                                                                        value="<%=FeedbackParticipantType.OWN_TEAM_MEMBERS%>"
                                                                                        <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.OWN_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox giverCheckbox"
                                                                                        type="checkbox"
                                                                                        value="<%=FeedbackParticipantType.OWN_TEAM_MEMBERS%>"
                                                                                        <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.OWN_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            }
                                                                        %>
                                                                        <% if (question.recipientType != FeedbackParticipantType.INSTRUCTORS
                                                                                && question.recipientType != FeedbackParticipantType.SELF
                                                                                && question.recipientType != FeedbackParticipantType.NONE
                                                                                && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)) {
                                                                        %>
                                                                            <tr id="response-recipient-team-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                                <td class="text-left">
                                                                                    <div data-toggle="tooltip"
                                                                                        data-placement="top" title=""
                                                                                        data-original-title="Control what team members of response recipient(s) can view">
                                                                                        Response Recipient's Team Members</div>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox answerCheckbox"
                                                                                        type="checkbox"
                                                                                        value="<%=FeedbackParticipantType.RECEIVER_TEAM_MEMBERS%>"
                                                                                        <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox giverCheckbox"
                                                                                        type="checkbox"
                                                                                        value="<%=FeedbackParticipantType.RECEIVER_TEAM_MEMBERS%>"
                                                                                        <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            }
                                                                        %>
                                                                        <%
                                                                            if (question.isResponseVisibleTo(FeedbackParticipantType.STUDENTS)) {
                                                                        %>
                                                                            <tr id="response-students-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                                <td class="text-left">
                                                                                    <div data-toggle="tooltip"
                                                                                        data-placement="top" title=""
                                                                                        data-original-title="Control what other students in this course can view">
                                                                                        Other students in this course</div>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox answerCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.STUDENTS%>"
                                                                                        <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.STUDENTS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox giverCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.STUDENTS%>"
                                                                                        <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.STUDENTS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            }
                                                                        %>
                                                                        <%
                                                                            if (question.isResponseVisibleTo(FeedbackParticipantType.INSTRUCTORS)) {
                                                                        %>
                                                                            <tr id="response-instructors-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">
                                                                                <td class="text-left">
                                                                                    <div data-toggle="tooltip"
                                                                                        data-placement="top" title=""
                                                                                        data-original-title="Control what instructors can view">
                                                                                        Instructors</div>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox answerCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.INSTRUCTORS%>"
                                                                                        <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.INSTRUCTORS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                                <td>
                                                                                    <input class="visibilityCheckbox giverCheckbox"
                                                                                        type="checkbox" value="<%=FeedbackParticipantType.INSTRUCTORS%>"
                                                                                        <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.INSTRUCTORS)?"checked=\"checked\"":""%>>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            }
                                                                        %>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                            <textarea class="form-control" rows="3" placeholder="Your comment about this response" name="<%=Const.ParamsNames.FEEDBACK_RESPONSE_COMMENT_TEXT%>" id="responseCommentAddForm-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}"></textarea>
                                                        </div>
                                                        <div class="col-sm-offset-5">
                                                            <a href="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESPONSE_COMMENT_ADD%>" type="button" class="btn btn-primary" id="button_save_comment_for_add-${recipientIndex.count}-<%=giverIndex%>-${questionIndex.count}">Add</a>
                                                            <input type="button" class="btn btn-default" value="Cancel" onclick="hideResponseCommentAddForm(${recipientIndex.count},<%=giverIndex%>,${questionIndex.count})">
                                                            <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID %>" value="${data.courseId}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME %>" value="${data.feedbackSessionName}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_QUESTION_ID %>" value="${response.questionId}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESPONSE_ID %>" value="${response.responseId}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="${data.account.googleId}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.RESPONSE_COMMENTS_SHOWCOMMENTSTO%>" value="${response.responseCommentVisibility}">
                                                            <input type="hidden" name="<%=Const.ParamsNames.RESPONSE_COMMENTS_SHOWGIVERTO%>" value="${response.responseCommentGiverNameVisibility}">
                                                        </div>
                                                    </form>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty responses}">
                                    <div class="col-sm-12" style="color:red;">No feedback from this user.</div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div></div></div>
                <%
                    }
                %>

                <%

                    // print out the "missing response" rows for the last team
                    Set<String> teamMembersWithoutReceivingResponses = teamMembersEmail;

                    teamMembersWithoutReceivingResponses.removeAll(teamMembersWithResponses);
                    List<String> teamMembersWithNoResponses = new ArrayList<String>(teamMembersWithoutReceivingResponses);
                    Collections.sort(teamMembersWithNoResponses);
                    
                    for (String email : teamMembersWithNoResponses) {
                %>
                    <% 
                        boolean isAllowedToModerate = data.instructor.isAllowedForPrivilege(
                                data.bundle.getSectionFromRoster(email), data.feedbackSessionName,
                                Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                        InstructorResultsModerationButton moderationButton = new InstructorResultsModerationButton(
                                !isAllowedToModerate, "btn btn-default btn-xs", email, data.courseId, data.feedbackSessionName,
                                null, "Moderate Responses");
                        
                        String profilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, email).isEmpty()
                                                ? data.getProfilePictureLink(email) : null;
                        
                        GRQNoResponseRow responseHeader = new GRQNoResponseRow(
                                email, data.bundle.getFullNameFromRoster(email),
                                profilePicture, moderationButton);
                        pageContext.setAttribute("responseHeader", responseHeader);
                    %>
                    <r:grqResponse response="${responseHeader}" isCollapsed="${data.shouldCollapsed}" />
                <%
                    }

                    //close the last team panel.
                    if (groupByTeamEnabled) {
                %>
                    </div></div></div>
                <%
                    }
                        
                    Set<String> teamsWithNoResponseGiven = new HashSet<String>(teamsInSection);
                    teamsWithNoResponseGiven.removeAll(givingTeams);
                
                    List<String> teamsWithNoResponseGivenList = new ArrayList<String>(teamsWithNoResponseGiven);
                    Collections.sort(teamsWithNoResponseGivenList);
                    for (String teamWithNoResponseGiven: teamsWithNoResponseGivenList) {
                %>
                    <%
                        if (groupByTeamEnabled) {
                    %>
                        <div class="panel panel-warning">
                            <div class="panel-heading">
                                <div class="inline panel-heading-text">
                                    <strong> <%=teamWithNoResponseGiven%></strong>
                                </div>
                                <span class="glyphicon pull-right glyphicon-chevron-up"></span>
                            </div>
                            <div class="panel-collapse collapse in">
                                <div class="panel-body background-color-warning">
                    <%
                        }
                        List<String> teamMembers = new ArrayList<String>(data.bundle.getTeamMembersFromRoster(teamWithNoResponseGiven));
                        Collections.sort(teamMembers);
                        for (String teamMember : teamMembers) {
                    %>
                        <% 
                            boolean isAllowedToModerate = data.instructor.isAllowedForPrivilege(
                                    data.bundle.getSectionFromRoster(teamMember), data.feedbackSessionName,
                                    Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                            InstructorResultsModerationButton moderationButton = new InstructorResultsModerationButton(
                                    !isAllowedToModerate, "btn btn-default btn-xs", teamMember, data.courseId, data.feedbackSessionName,
                                    null, "Moderate Responses");
                            
                            String profilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, teamMember).isEmpty()
                                                    ? data.getProfilePictureLink(teamMember) : null;
                            
                            GRQNoResponseRow responseHeader = new GRQNoResponseRow(
                                    teamMember, data.bundle.getFullNameFromRoster(teamMember),
                                    profilePicture, moderationButton);
                            pageContext.setAttribute("responseHeader", responseHeader);
                        %>
                        <r:grqResponse response="${responseHeader}" isCollapsed="${data.shouldCollapsed}" />
                    <%
                        }
                        if (groupByTeamEnabled) {
                    %>
                        </div></div></div>                
                    <%
                        }
                    %>
                <%
                    }
                %>
            </div>
        </div>
    </div>
            <%
                Set<String> sectionsWithNoResponseReceived = new HashSet<String>(sectionsInCourse);
                sectionsWithNoResponseReceived.removeAll(givingSections);
                
                if (data.selectedSection.equals("All")) {
            %>
                <%
                    List<String> sectionsList = new ArrayList<String>(sectionsWithNoResponseReceived);
                    Collections.sort(sectionsList);
                    for (String sectionWithNoResponseReceived: sectionsWithNoResponseReceived) {
                %>
                    <div class="panel panel-success">
                        <div class="panel-heading">
                            <div class="inline panel-heading-text">
                                <strong> <%=sectionWithNoResponseReceived%></strong>
                            </div>
                            <span class="glyphicon pull-right glyphicon-chevron-up"></span>
                        </div>
                        <div class="panel-collapse collapse in">
                            <div class="panel-body">
                                <%
                                    Set<String> teamsFromSection = data.bundle.getTeamsInSectionFromRoster(sectionWithNoResponseReceived);
                                    List<String> teamsFromSectionList = new ArrayList<String>(teamsFromSection);
                                    Collections.sort(teamsFromSectionList);
                                    
                                    for (String team : teamsFromSectionList) {
                                %>
                                    <%
                                        List<String> teamMembers = new ArrayList<String>(data.bundle.getTeamMembersFromRoster(team));
                                        Collections.sort(teamMembers);
                                        if (groupByTeamEnabled) {
                                    %>
                                        <div class="panel panel-warning">
                                            <div class="panel-heading">
                                                <div class="inline panel-heading-text">
                                                    <strong> <%=team%></strong>
                                                </div>
                                                <span class="glyphicon pull-right glyphicon-chevron-up"></span>
                                            </div>
                                            <div class="panel-collapse collapse in">
                                                <div class="panel-body background-color-warning">
                                    <%
                                        }
                                        for (String teamMember : teamMembers) {
                                    %>
                                        <% 
                                            boolean isAllowedToModerate = data.instructor.isAllowedForPrivilege(
                                                    data.bundle.getSectionFromRoster(teamMember), data.feedbackSessionName,
                                                    Const.ParamsNames.INSTRUCTOR_PERMISSION_MODIFY_SESSION_COMMENT_IN_SECTIONS);
                                            InstructorResultsModerationButton moderationButton = new InstructorResultsModerationButton(
                                                    !isAllowedToModerate, "btn btn-default btn-xs", teamMember, data.courseId, data.feedbackSessionName,
                                                    null, "Moderate Responses");
                                            
                                            String profilePicture = validator.getInvalidityInfo(FieldValidator.FieldType.EMAIL, teamMember).isEmpty()
                                                                    ? data.getProfilePictureLink(teamMember) : null;
                                            
                                            GRQNoResponseRow responseHeader = new GRQNoResponseRow(
                                                    teamMember, data.bundle.getFullNameFromRoster(teamMember),
                                                    profilePicture, moderationButton);
                                            pageContext.setAttribute("responseHeader", responseHeader);
                                        %>
                                        <r:grqResponse response="${responseHeader}" isCollapsed="${data.shouldCollapsed}" />
                                    <% 
                                        }
                                        if (groupByTeamEnabled) {
                                    %>
                                        </div></div></div>
                                    <%
                                        }
                                    %>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                <%
                    }
                %>
            <%
                }
            %>
        <%
            }
        %>

        <jsp:include page="<%=Const.ViewURIs.INSTRUCTOR_FEEDBACK_RESULTS_BOTTOM%>" />
        </div>
    </div>

    <jsp:include page="<%=Const.ViewURIs.FOOTER%>" />
</body>
</html>
