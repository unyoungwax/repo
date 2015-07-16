<%@ tag description="instructorFeedbackResults - GRQ - No Response Row" %>
<%@ tag import="teammates.common.util.Const" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib tagdir="/WEB-INF/tags/instructor/results" prefix="r" %>

<%@ attribute name="response" type="teammates.ui.template.GRQNoResponseRow" required="true" %>
<%@ attribute name="isCollapsed" required="true" %>
<div class="panel panel-default">
    <div class="panel-heading">
        From:
        <div class="inline panel-heading-text<c:if test="${not empty response.profilePicture}"> middlealign profile-pic-icon-hover" data-link="${response.profilePicture}</c:if>">
            <strong>${response.name}</strong>
            <c:if test="${not empty response.profilePicture}"><img src="" alt="No Image Given" class="hidden profile-pic-icon-hidden"></c:if>
            <a href="mailTo:${response.email}">[${response.email}]</a>
        </div>
        <div class="pull-right">
            <r:moderationsButton moderationButton="${response.moderationButton}" />
            &nbsp;
            <div class="display-icon" style="display:inline;">
                <span class="glyphicon pull-right${isCollapsed ? ' glyphicon-chevron-down' : ' glyphicon-chevron-up'}"></span>
            </div>                
        </div>
    </div>
    <div class="panel-collapse collapse in">
        <div class="panel-body"> 
            <i>There are no responses given by this user</i> 
        </div>
    </div>
</div>