package teammates.ui.template;

import java.util.List;

public class InstructorResultsRecipientResponsePanel {
    private String recipientName;
    private String recipientProfilePicture;
    private List<InstructorResultsResponsePanel> responsePanels;
    
    public InstructorResultsRecipientResponsePanel(String recipientName, String recipientProfilePicture,
            List<InstructorResultsResponsePanel> responsePanels) {
        this.recipientName = recipientName;
        this.recipientProfilePicture = recipientProfilePicture;
        this.responsePanels = responsePanels;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public String getRecipientProfilePicture() {
        return recipientProfilePicture;
    }

    public List<InstructorResultsResponsePanel> getResponsePanels() {
        return responsePanels;
    }
}
