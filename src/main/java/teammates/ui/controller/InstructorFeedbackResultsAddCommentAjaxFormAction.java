package teammates.ui.controller;

import teammates.common.datatransfer.FeedbackQuestionAttributes;
import teammates.common.datatransfer.FeedbackResponseAttributes;
import teammates.common.datatransfer.FeedbackResponseCommentAttributes;
import teammates.common.datatransfer.FeedbackSessionAttributes;
import teammates.common.datatransfer.InstructorAttributes;
import teammates.common.exception.EntityDoesNotExistException;
import teammates.common.util.Assumption;
import teammates.common.util.Const;
import teammates.logic.api.GateKeeper;


/**
 * Action: Get a form to add a {@link FeedbackResponseCommentAttributes}
 */
public class InstructorFeedbackResultsAddCommentAjaxFormAction extends Action {

    @Override
    protected ActionResult execute() throws EntityDoesNotExistException {
        String courseId = getRequestParamValue(Const.ParamsNames.COURSE_ID);
        Assumption.assertNotNull("null course id", courseId);
        String feedbackSessionName = getRequestParamValue(Const.ParamsNames.FEEDBACK_SESSION_NAME);
        Assumption.assertNotNull("null feedback session name", feedbackSessionName);
        String feedbackQuestionId = getRequestParamValue(Const.ParamsNames.FEEDBACK_QUESTION_ID);
        Assumption.assertNotNull("null feedback question id", feedbackQuestionId);
        String feedbackResponseId = getRequestParamValue(Const.ParamsNames.FEEDBACK_RESPONSE_ID);
        Assumption.assertNotNull("null feedback response id", feedbackResponseId);
        
        InstructorAttributes instructor = logic.getInstructorForGoogleId(courseId, account.googleId);
        System.out.println(account.googleId);
        Assumption.assertNotNull(instructor);
        FeedbackSessionAttributes session = logic.getFeedbackSession(feedbackSessionName, courseId);
        Assumption.assertNotNull(session);
        FeedbackQuestionAttributes question = logic.getFeedbackQuestion(feedbackQuestionId);
        Assumption.assertNotNull(question);
        FeedbackResponseAttributes response = logic.getFeedbackResponse(feedbackResponseId);
        Assumption.assertNotNull(response);
        
        
        boolean isCreatorOnly = true;
        new GateKeeper().verifyAccessible(instructor, session, !isCreatorOnly, response.giverSection, 
                Const.ParamsNames.INSTRUCTOR_PERMISSION_SUBMIT_SESSION_IN_SECTIONS);
        new GateKeeper().verifyAccessible(instructor, session, !isCreatorOnly, response.recipientSection, 
                Const.ParamsNames.INSTRUCTOR_PERMISSION_SUBMIT_SESSION_IN_SECTIONS);
      
        
        InstructorFeedbackResultsAddResponseCommentFormData data = new InstructorFeedbackResultsAddResponseCommentFormData(account);
        data.question = question;
        data.response = response;
        
        return createShowPageResult(Const.ViewURIs.INSTRUCTOR_FEEDBACK_RESULTS_ADD_RESPONSE_COMMENT_FORM, data);
    }

}
