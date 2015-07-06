package teammates.ui.controller;

import teammates.common.datatransfer.AccountAttributes;
import teammates.common.datatransfer.FeedbackQuestionAttributes;
import teammates.common.datatransfer.FeedbackResponseAttributes;
import teammates.common.datatransfer.InstructorAttributes;


public class InstructorFeedbackResultsAddResponseCommentFormData extends PageData {
    

    public FeedbackQuestionAttributes question;
    public FeedbackResponseAttributes response;
    
    // data used for identifying the form in the html
    // these are not used logically in this class
    public int giverIndex;
    public int recipientIndex;
    public int qnIndex;
    
    public InstructorAttributes instructor = null;
    

    public InstructorFeedbackResultsAddResponseCommentFormData(AccountAttributes account) {
        super(account);
    }

}
