package teammates.ui.controller;



import teammates.common.datatransfer.AccountAttributes;
import teammates.common.util.Url;

public class InstructorFeedbackEditCopyData extends PageData {
    public String redirectUrl;
    public String errorMessage;
    public boolean isError;
    
    public InstructorFeedbackEditCopyData(AccountAttributes account, 
                                          Url redirectUrl, boolean isError, String errorMessage) {
        super(account);
        this.redirectUrl = redirectUrl != null ? redirectUrl.toString() : "";
        this.isError = isError;
        this.errorMessage = errorMessage;
    }

  
}
