<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
<%@ page import="teammates.ui.controller.InstructorFeedbackResultsAddResponseCommentFormData"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionDetails"%>
<%@ page import="teammates.common.datatransfer.FeedbackQuestionAttributes"%>
<%
    InstructorFeedbackResultsAddResponseCommentFormData data = (InstructorFeedbackResultsAddResponseCommentFormData) request.getAttribute("data");
    FieldValidator validator = new FieldValidator();
    FeedbackQuestionAttributes question = data.question;
%>

<form class="responseCommentAddForm">
    <div class="form-group">
        <div class="form-group form-inline">
            <div class="form-group text-muted">
                <p>
                    Giver: <%=data.response.giverEmail%><br>
                    Recipient: <%=data.response.recipientEmail%>
                </p>
                You may change comment's visibility using the visibility options on the right hand side.
            </div>
            <a id="frComment-visibility-options-trigger-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>"
                class="btn btn-sm btn-info pull-right" onclick="toggleVisibilityEditForm(<%=data.recipientIndex%>,<%=data.giverIndex%>,<%=data.qnIndex%>)">
                <span class="glyphicon glyphicon-eye-close"></span>
                Show Visibility Options
            </a>
        </div>
        <div id="visibility-options-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>" class="panel panel-default"
            style="display: none;">
            <div class="panel-heading">Visibility Options</div>
            <table class="table text-center" style="color:#000;"
                style="background: #fff;">
                <tbody>
                    <tr>
                        <th class="text-center">User/Group</th>
                        <th class="text-center">Can see
                            your comment</th>
                        <th class="text-center">Can see
                            your name</th>
                    </tr>
                    <tr id="response-giver-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what response giver can view">
                                Response Giver</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox centered"
                            name="receiverLeaderCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.GIVER%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.GIVER)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.GIVER%>"
                            <%=data.isResponseCommentGiverNameVisibleTo( question, FeedbackParticipantType.GIVER)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% if(question.recipientType != FeedbackParticipantType.SELF
                            && question.recipientType != FeedbackParticipantType.NONE
                            && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER)){ %>
                    <tr id="response-recipient-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what response recipient(s) can view">
                                Response Recipient(s)</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox centered"
                            name="receiverLeaderCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.RECEIVER%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.RECEIVER)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.RECEIVER%>"
                            <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.RECEIVER)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% } %>
                    <% if(question.giverType != FeedbackParticipantType.INSTRUCTORS
                            && question.giverType != FeedbackParticipantType.SELF
                            && question.isResponseVisibleTo(FeedbackParticipantType.OWN_TEAM_MEMBERS)){ %>
                    <tr id="response-giver-team-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what team members of response giver can view">
                                Response Giver's Team Members</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox"
                            type="checkbox"
                            value="<%=FeedbackParticipantType.OWN_TEAM_MEMBERS%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.OWN_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox"
                            value="<%=FeedbackParticipantType.OWN_TEAM_MEMBERS%>"
                            <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.OWN_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% } %>
                    <% if(question.recipientType != FeedbackParticipantType.INSTRUCTORS
                            && question.recipientType != FeedbackParticipantType.SELF
                            && question.recipientType != FeedbackParticipantType.NONE
                            && question.isResponseVisibleTo(FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)){ %>
                    <tr id="response-recipient-team-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what team members of response recipient(s) can view">
                                Response Recipient's Team Members</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox"
                            type="checkbox"
                            value="<%=FeedbackParticipantType.RECEIVER_TEAM_MEMBERS%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox"
                            value="<%=FeedbackParticipantType.RECEIVER_TEAM_MEMBERS%>"
                            <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% } %>
                    <% if(question.isResponseVisibleTo(FeedbackParticipantType.STUDENTS)){ %>
                    <tr id="response-students-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what other students in this course can view">
                                Other students in this course</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.STUDENTS%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.STUDENTS)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.STUDENTS%>"
                            <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.STUDENTS)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% } %>
                    <% if(question.isResponseVisibleTo(FeedbackParticipantType.INSTRUCTORS)){ %>
                    <tr id="response-instructors-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">
                        <td class="text-left">
                            <div data-toggle="tooltip"
                                data-placement="top" title=""
                                data-original-title="Control what instructors can view">
                                Instructors</div>
                        </td>
                        <td><input
                            class="visibilityCheckbox answerCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.INSTRUCTORS%>"
                            <%=data.isResponseCommentVisibleTo(question, FeedbackParticipantType.INSTRUCTORS)?"checked=\"checked\"":""%>>
                        </td>
                        <td><input
                            class="visibilityCheckbox giverCheckbox"
                            type="checkbox" value="<%=FeedbackParticipantType.INSTRUCTORS%>"
                            <%=data.isResponseCommentGiverNameVisibleTo(question, FeedbackParticipantType.INSTRUCTORS)?"checked=\"checked\"":""%>>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <textarea class="form-control" rows="3" placeholder="Your comment about this response" name="<%=Const.ParamsNames.FEEDBACK_RESPONSE_COMMENT_TEXT%>" id="responseCommentAddForm-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>"></textarea>
    </div>
    <div class="col-sm-offset-5">
        <a href="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESPONSE_COMMENT_ADD%>" type="button" class="btn btn-primary" id="button_save_comment_for_add-<%=data.recipientIndex%>-<%=data.giverIndex%>-<%=data.qnIndex%>">Add</a>
        <input type="button" class="btn btn-default" value="Cancel" onclick="hideResponseCommentAddForm(<%=data.recipientIndex%>,<%=data.giverIndex%>,<%=data.qnIndex%>)">
        <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID %>" value="<%=data.response.courseId %>">
        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME %>" value="<%=data.response.feedbackSessionName %>">
        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_QUESTION_ID %>" value="<%=data.response.feedbackQuestionId %>">                                            
        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESPONSE_ID %>" value="<%=data.response.getId() %>">
        <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="<%=data.account.googleId %>">
        <input
            type="hidden"
            name="<%=Const.ParamsNames.RESPONSE_COMMENTS_SHOWCOMMENTSTO%>"
            value="<%=data.getResponseCommentVisibilityString(question)%>">
        <input
            type="hidden"
            name="<%=Const.ParamsNames.RESPONSE_COMMENTS_SHOWGIVERTO%>"
            value="<%=data.getResponseCommentGiverNameVisibilityString(question)%>">
    </div>
</form>