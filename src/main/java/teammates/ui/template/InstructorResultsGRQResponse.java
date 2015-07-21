package teammates.ui.template;

import java.util.List;

import teammates.common.datatransfer.FeedbackQuestionAttributes;

public class InstructorResultsGRQResponse {
    @Deprecated
    private FeedbackQuestionAttributes question;
    private String questionId;
    private String responseId;
    private int questionNumber;
    private String questionHtml;
    private String answerHtml;
    private boolean isAllowedToSubmitSessionInSections;
    private List<FeedbackResponseComment> comments;
    private String responseCommentVisibility;
    private String responseCommentGiverNameVisibility; 
    
    public InstructorResultsGRQResponse(String questionId, String responseId,
            int questionNumber, String questionHtml, String answerHtml,
            boolean isAllowedToSubmitSessionInSections, List<FeedbackResponseComment> comments,
            String responseCommentVisibility, String responseCommentGiverNameVisibility) {
        this.questionId = questionId;
        this.responseId = responseId;
        this.questionNumber = questionNumber;
        this.questionHtml = questionHtml;
        this.answerHtml = answerHtml;
        this.isAllowedToSubmitSessionInSections = isAllowedToSubmitSessionInSections;
        this.comments = comments;
        this.responseCommentVisibility = responseCommentVisibility;
        this.responseCommentGiverNameVisibility = responseCommentGiverNameVisibility;
    }
    
    public String getQuestionId() {
        return questionId;
    }
    
    public String getResponseId() {
        return responseId;
    }

    public int getQuestionNumber() {
        return questionNumber;
    }

    public String getQuestionHtml() {
        return questionHtml;
    }

    public String getAnswerHtml() {
        return answerHtml;
    }

    public boolean isAllowedToSubmitSessionInSections() {
        return isAllowedToSubmitSessionInSections;
    }
    
    public List<FeedbackResponseComment> getComments() {
        return comments;
    }
    
    public String getResponseCommentVisibility() {
        return responseCommentVisibility;
    }
    
    public String getResponseCommentGiverNameVisibility() {
        return responseCommentGiverNameVisibility;
    }
    
    @Deprecated
    public void setQuestion(FeedbackQuestionAttributes question) {
        this.question = question;
    }
    
    @Deprecated
    public FeedbackQuestionAttributes getQuestion() {
        return question;
    }
}
