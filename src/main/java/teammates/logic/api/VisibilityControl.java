package teammates.logic.api;

import teammates.common.datatransfer.CommentAttributes;
import teammates.common.datatransfer.CommentParticipantType;
import teammates.common.datatransfer.FeedbackParticipantType;
import teammates.common.datatransfer.FeedbackResponseCommentAttributes;

public class VisibilityControl {

    public static boolean isCommentPublicToRecipient(CommentAttributes comment) {
        return comment.showCommentTo != null
                && (comment.isVisibleTo(CommentParticipantType.PERSON)
                    || comment.isVisibleTo(CommentParticipantType.TEAM)
                    || comment.isVisibleTo(CommentParticipantType.SECTION)
                    || comment.isVisibleTo(CommentParticipantType.COURSE));
    }
    
    public static boolean isResponseCommentPublicToRecipient(FeedbackResponseCommentAttributes comment) {
        return (comment.isVisibleTo(FeedbackParticipantType.GIVER)
             || comment.isVisibleTo(FeedbackParticipantType.RECEIVER)
             || comment.isVisibleTo(FeedbackParticipantType.OWN_TEAM_MEMBERS)
             || comment.isVisibleTo(FeedbackParticipantType.RECEIVER_TEAM_MEMBERS)
             || comment.isVisibleTo(FeedbackParticipantType.STUDENTS));
    }
}
