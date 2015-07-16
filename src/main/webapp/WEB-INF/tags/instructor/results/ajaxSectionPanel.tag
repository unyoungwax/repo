<%-- TODO: Rename, re-describe and tidy up --%>
<%@ tag description="instructorFeedbackResultsGRQ - !showAll at start" %>
<%@ tag import="teammates.common.util.Const" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ attribute name="data" type="teammates.ui.controller.InstructorFeedbackResultsPageData" required="true" %>
<%@ attribute name="EXCEEDING_RESPONSES_ERROR_MESSAGE" required="true" %>
<c:set var="sectionIndex" value="0" />
<c:choose>
    <c:when test="${data.allSectionsSelected}">
        <c:forEach items="${data.sections}" var="section">
            <div class="panel panel-success">
                <div class="panel-heading ajax_submit">
                    <div class="row">
                        <div class="col-sm-9 panel-heading-text">
                            <strong>${section}</strong>
                        </div>
                        <div class="col-sm-3">
                            <div class="pull-right">
                                <a class="btn btn-success btn-xs" id="collapse-panels-button-section-${sectionIndex}" data-toggle="tooltip" title="Collapse or expand all ${data.groupedByTeam ? 'team' : 'student'} panels. You can also click on the panel heading to toggle each one individually." style="display:none;">
                                    Expand ${data.groupedByTeam ? 'Teams' : 'Students'}
                                </a>
                                &nbsp;
                                <div class="display-icon" style="display:inline;">
                                    <span class="glyphicon glyphicon-chevron-down"></span>
                                </div>
                            </div>
                         </div>
                    </div>

                    <form style="display:none;" id="seeMore-${sectionIndex}" class="seeMoreForm-${sectionIndex}" action="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_PAGE%>">
                        <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID%>" value="${data.courseId}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME%>" value="${data.feedbackSessionName}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYSECTION%>" value="${section}">
                        <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="${data.account.googleId}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" value="${data.groupedByTeam}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SORTTYPE%>" value="${data.sortType}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SHOWSTATS%>" value="on" id="showStats-${sectionIndex}">
                        <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_MAIN_INDEX%>" value="on" id="mainIndex-${sectionIndex}">
                    </form>
                </div>
                <div class="panel-collapse collapse">
                    <div class="panel-body">
                    
                    </div>
                </div>
            </div>
            <c:set var="sectionIndex" value="${sectionIndex + 1}" />
        </c:forEach>
        <div class="panel panel-success">
            <div class="panel-heading ajax_submit">
                <div class="row">
                    <div class="col-sm-9 panel-heading-text">
                        <strong>Not in a section</strong>
                    </div>
                    <div class="col-sm-3">
                        <div class="pull-right">
                            <a class="btn btn-success btn-xs" id="collapse-panels-button-section-${sectionIndex}" data-toggle="tooltip" title="Collapse or expand all ${data.groupedByTeam ? 'team' : 'student'} panels. You can also click on the panel heading to toggle each one individually." style="display:none;">
                                Expand ${data.groupedByTeam ? 'Teams' : 'Students'}
                            </a>
                            &nbsp;
                            <div class="display-icon" style="display:inline;">
                                <span class="glyphicon glyphicon-chevron-down"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <form style="display:none;" id="seeMore-${sectionIndex}" class="seeMoreForm-${sectionIndex}" action="<%=Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_PAGE%>">
                    <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID%>" value="${data.courseId}">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME%>" value="${data.feedbackSessionName}">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYSECTION%>" value="None">
                    <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" value="${data.account.googleId}">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" value="${data.groupedByTeam}">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SORTTYPE%>" value="${data.sortType}">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SHOWSTATS%>" value="on">
                    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_MAIN_INDEX%>" value="on" id="mainIndex-${sectionIndex}">
                </form>
            </div>
            <div class="panel-collapse collapse">
                <div class="panel-body">

                </div>
            </div>
        </div>
    </c:when>
    <c:otherwise>
        <div class="panel panel-success">
            <div class="panel-heading">
                <div class="row">
                    <div class="col-sm-9 panel-heading-text">
                        <strong>${data.selectedSection}</strong>                   
                    </div>
                    <div class="col-sm-3">
                        <div class="pull-right">
                            <span class="glyphicon glyphicon-chevron-up"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel-collapse collapse in">
                <div class="panel-body" id="sectionBody-0">
                    ${EXCEEDING_RESPONSES_ERROR_MESSAGE}
                </div>
            </div>
        </div>
    </c:otherwise>
</c:choose>