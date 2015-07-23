package teammates.ui.template;

import java.util.List;

public class InstructorResultsSectionPanel {
    private String sectionName;
    private List<InstructorResultsTeamPanel> teamPanels;
    
    public InstructorResultsSectionPanel(String sectionName, List<InstructorResultsTeamPanel> teamPanels) {
        this.sectionName = sectionName;
        this.teamPanels = teamPanels;
    }

    public String getSectionName() {
        return sectionName;
    }

    public List<InstructorResultsTeamPanel> getTeamPanels() {
        return teamPanels;
    }
}
