package teammates.ui.template;

import java.util.List;

public class InstructorResultsGiverResponsePanel {
    private String giverEmail;
    private String giverName;
    private String giverProfilePicture;
    private boolean isGiverVisibleToCurrentUser;
    private InstructorResultsModerationButton moderationButton;
    private List<InstructorResultsRecipientResponsePanel> recipientResponsePanels;
    
    public InstructorResultsGiverResponsePanel(String giverEmail, String giverName, String giverProfilePicture,
            boolean isGiverVisibleToCurrentUser, InstructorResultsModerationButton moderationButton,
            List<InstructorResultsRecipientResponsePanel> recipientResponsePanels) {
        this.giverEmail = giverEmail;
        this.giverName = giverName;
        this.giverProfilePicture = giverProfilePicture;
        this.isGiverVisibleToCurrentUser = isGiverVisibleToCurrentUser;
        this.moderationButton = moderationButton;
        this.recipientResponsePanels = recipientResponsePanels;
    }

    public String getGiverEmail() {
        return giverEmail;
    }

    public String getGiverName() {
        return giverName;
    }

    public String getGiverProfilePicture() {
        return giverProfilePicture;
    }
    
    public boolean isGiverVisibleToCurrentUser() {
        return isGiverVisibleToCurrentUser;
    }

    public InstructorResultsModerationButton getModerationButton() {
        return moderationButton;
    }
    
    public List<InstructorResultsRecipientResponsePanel> getRecipientResponsePanels() {
        return recipientResponsePanels;
    }
}
