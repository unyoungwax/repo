package teammates.ui.template;

public class GRQNoResponseRow {
    private InstructorResultsModerationButton moderationButton;
    private String profilePicture;
    private String name;
    private String email;
    
    public GRQNoResponseRow(String email, String name, String profilePicture,
                            InstructorResultsModerationButton moderationButton) {
        this.email = email;
        this.name = name;
        this.profilePicture = profilePicture;
        this.moderationButton = moderationButton;
    }

    public InstructorResultsModerationButton getModerationButton() {
        return moderationButton;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }
}
