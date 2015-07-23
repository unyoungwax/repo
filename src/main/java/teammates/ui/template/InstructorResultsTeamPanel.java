package teammates.ui.template;

import java.util.List;

public class InstructorResultsTeamPanel {
    // name is null if not grouped by team on Results page
    private String teamName;
    private List<InstructorResultsGiverResponsePanel> giverResponsePanels;
    private List<InstructorResultsGiverResponsePanel> noResponsePanels;

    public InstructorResultsTeamPanel(String teamName,
                                      List<InstructorResultsGiverResponsePanel> giverResponsePanels,
                                      List<InstructorResultsGiverResponsePanel> noResponsePanels) {
        this.teamName = teamName;
        this.giverResponsePanels = giverResponsePanels;
        this.noResponsePanels = noResponsePanels;
    }
    
    public String getTeamName() {
        return teamName;
    }

    public List<InstructorResultsGiverResponsePanel> getGiverResponsePanels() {
        return giverResponsePanels;
    }
    
    public List<InstructorResultsGiverResponsePanel> getNoResponsePanels() {
        return noResponsePanels;
    }
}
