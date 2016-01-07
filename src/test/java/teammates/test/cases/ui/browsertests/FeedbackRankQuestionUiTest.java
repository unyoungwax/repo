package teammates.test.cases.ui.browsertests;

import static org.testng.AssertJUnit.assertEquals;
import static org.testng.AssertJUnit.assertFalse;
import static org.testng.AssertJUnit.assertNotNull;
import static org.testng.AssertJUnit.assertNull;
import static org.testng.AssertJUnit.assertTrue;

import org.openqa.selenium.By;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import teammates.common.datatransfer.DataBundle;
import teammates.common.datatransfer.FeedbackQuestionAttributes;
import teammates.common.datatransfer.FeedbackRankOptionsQuestionDetails;
import teammates.common.datatransfer.StudentAttributes;
import teammates.common.util.AppUrl;
import teammates.common.util.Const;
import teammates.test.driver.BackDoor;
import teammates.test.pageobjects.Browser;
import teammates.test.pageobjects.BrowserPool;
import teammates.test.pageobjects.FeedbackQuestionSubmitPage;
import teammates.test.pageobjects.FeedbackSubmitPage;
import teammates.test.pageobjects.InstructorFeedbackEditPage;
import teammates.test.pageobjects.InstructorFeedbackResultsPage;
import teammates.test.pageobjects.StudentFeedbackResultsPage;

public class FeedbackRankQuestionUiTest extends FeedbackQuestionUiTest {
    private static Browser browser;
    private static InstructorFeedbackEditPage feedbackEditPage;
    
    private static InstructorFeedbackResultsPage instructorResultsPage;
    private static StudentFeedbackResultsPage studentResultsPage;
    
    private static DataBundle testData;

    private static String instructorCourseId;
    private static String instructorEditFSName;
    private static String instructorId;
    
    @BeforeClass
    public void classSetup() throws Exception {
        printTestClassHeader();
        testData = loadDataBundle("/FeedbackRankQuestionUiTest.json");
        removeAndRestoreTestDataOnServer(testData);
        browser = BrowserPool.getBrowser();
        
        instructorId = testData.accounts.get("instructor1").googleId;
        instructorCourseId = testData.courses.get("course").id;
        instructorEditFSName = testData.feedbackSessions.get("edit").feedbackSessionName;

    }
    
    
    @Test
    public void testStudentSubmitAndResultsPages() {
        ______TS("Rank submission: input disabled for closed session");
        
        FeedbackSubmitPage submitPage = loginToStudentFeedbackSubmitPage("alice.tmms@FRankUiT.CS4221", "closed");
        assertTrue(submitPage.isElementVisible(Const.ParamsNames.FEEDBACK_RESPONSE_TEXT + "-1-0-0"));
        assertFalse(submitPage.isElementEnabled(Const.ParamsNames.FEEDBACK_RESPONSE_TEXT + "-1-0-0"));
        
        
        ______TS("Rank options: single question submission page");
        FeedbackQuestionAttributes singleRankOptionsFq = BackDoor.getFeedbackQuestion("FRankUiT.CS4221", "Student Session", 1);
        assertNull(BackDoor.getFeedbackResponse(singleRankOptionsFq.getId(),
                                                "alice.b.tmms@gmail.tmt",
                                                "tmms.helper1@gmail.tmt"));
        FeedbackQuestionSubmitPage rankOptionsQuestionSubmitPage = loginToStudentFeedbackQuestionSubmitPage(
                                                                        "alice.tmms@FRankUiT.CS4221", 
                                                                        "student", singleRankOptionsFq.getId());

        rankOptionsQuestionSubmitPage.selectResponseTextDropdown(1, 0, 0, "2");
        rankOptionsQuestionSubmitPage.selectResponseTextDropdown(1, 0, 1, "1");
        
        rankOptionsQuestionSubmitPage.selectResponseTextDropdown(1, 1, 1, "1");
        
        rankOptionsQuestionSubmitPage.clickSubmitButton();
        assertEquals(Const.StatusMessages.FEEDBACK_RESPONSES_SAVED, rankOptionsQuestionSubmitPage.getStatus());
        
        assertNotNull(BackDoor.getFeedbackResponse(singleRankOptionsFq.getId(),
                                                   "alice.b.tmms@gmail.tmt",
                                                   "tmms.helper1@gmail.tmt"));
        
        ______TS("Rank recipients: single question submission page");
        FeedbackQuestionAttributes singleRankRecipientsfq = BackDoor.getFeedbackQuestion("FRankUiT.CS4221", "Student Session", 3);
        FeedbackQuestionSubmitPage rankRecipientsQuestionSubmitPage = loginToStudentFeedbackQuestionSubmitPage("alice.tmms@FRankUiT.CS4221", "student", singleRankRecipientsfq.getId());
        
        assertNull(BackDoor.getFeedbackResponse(singleRankRecipientsfq.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "alice.b.tmms@gmail.tmt"));
        assertNull(BackDoor.getFeedbackResponse(singleRankRecipientsfq.getId(),
                                         "alice.b.tmms@gmail.tmt",
                                         "benny.c.tmms@gmail.tmt"));

        rankRecipientsQuestionSubmitPage.selectResponseTextDropdown(1, 0, 0, "2");
        rankRecipientsQuestionSubmitPage.selectResponseTextDropdown(1, 1, 0, "1");
        
        rankRecipientsQuestionSubmitPage.selectResponseTextDropdown(1, 1, 0, "1");
        
        rankRecipientsQuestionSubmitPage.clickSubmitButton();
        assertEquals(Const.StatusMessages.FEEDBACK_RESPONSES_SAVED, rankRecipientsQuestionSubmitPage.getStatus());
        
        assertNotNull(BackDoor.getFeedbackResponse(singleRankRecipientsfq.getId(),
                                                   "alice.b.tmms@gmail.tmt",
                                                   "alice.b.tmms@gmail.tmt"));
        assertNotNull(BackDoor.getFeedbackResponse(singleRankRecipientsfq.getId(),
                                                    "alice.b.tmms@gmail.tmt",
                                                    "benny.c.tmms@gmail.tmt"));
        
        
        ______TS("Rank submission");
        
        submitPage = loginToStudentFeedbackSubmitPage("alice.tmms@FRankUiT.CS4221", "student");
        
        // verifies that question submit form without existing responses loads correctly
        System.setProperty("godmode", "true");
        submitPage.verifyHtmlMainContent("/studentFeedbackSubmitPageRank.html");
        System.setProperty("godmode", "false");
       
        submitPage.selectResponseTextDropdown(1, 0, 0, "1");
        submitPage.selectResponseTextDropdown(1, 0, 1, "2");
        
        // to check if deleting responses work
        submitPage.selectResponseTextDropdown(1, 1, 1, "");
        assertEquals("Please rank the above options.", submitPage.getRankMessage(1, 1));
        
        
        submitPage.selectResponseTextDropdown(2, 0, 0, "1");
        submitPage.selectResponseTextDropdown(2, 1, 0, "2");
        
        // test rank messages
        assertEquals("Please rank the above recipients.", submitPage.getRankMessage(5, 3));
        submitPage.selectResponseTextDropdown(5, 0, 0, "2");
        assertTrue(submitPage.getRankMessage(5, 0).isEmpty());
        submitPage.selectResponseTextDropdown(5, 1, 0, "2");
        assertEquals("The same rank should not be given multiple times.", submitPage.getRankMessage(5, 3));
        
        // try to submit with error
        submitPage.clickSubmitButton();
        assertEquals("Please fix the error(s) for rank question(s) 5. To skip a rank question, leave all the boxes blank.", submitPage.getStatus());
        
        submitPage.selectResponseTextDropdown(5, 1, 0, "1");
        assertEquals("Please rank the above recipients.", submitPage.getRankMessage(5, 3));
        
        // Submit
        submitPage.clickSubmitButton();
        assertEquals(Const.StatusMessages.FEEDBACK_RESPONSES_SAVED, submitPage.getStatus());
        
        FeedbackQuestionAttributes fq1 = BackDoor.getFeedbackQuestion("FRankUiT.CS4221", "Student Session", 1);
        assertNotNull(BackDoor.getFeedbackResponse(fq1.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "tmms.helper1@gmail.tmt"));
        assertNull(BackDoor.getFeedbackResponse(fq1.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "tmms.test@gmail.tmt"));
        
        FeedbackQuestionAttributes fq2 = BackDoor.getFeedbackQuestion("FRankUiT.CS4221", "Student Session", 2);
        assertNotNull(BackDoor.getFeedbackResponse(fq2.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "tmms.helper1@gmail.tmt"));
        assertNotNull(BackDoor.getFeedbackResponse(fq2.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "tmms.test@gmail.tmt"));
        
        FeedbackQuestionAttributes fq3 = BackDoor.getFeedbackQuestion("FRankUiT.CS4221", "Student Session", 3);
        assertNotNull(BackDoor.getFeedbackResponse(fq3.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "alice.b.tmms@gmail.tmt"));
        assertNotNull(BackDoor.getFeedbackResponse(fq3.getId(),
                                        "alice.b.tmms@gmail.tmt",
                                        "benny.c.tmms@gmail.tmt"));
        
        // Go back to submission page and verify html
        submitPage = loginToStudentFeedbackSubmitPage("alice.tmms@FRankUiT.CS4221", "student");
        
        // try to submit duplicate ranks for question that permits it
        submitPage.selectResponseTextDropdown(6, 0, 0, "1");
        submitPage.selectResponseTextDropdown(6, 1, 0, "1");
        assertTrue("No error message expected", submitPage.getRankMessage(6, 0).isEmpty());
        
        submitPage.selectResponseTextDropdown(1, 0, 0, "3");
        assertEquals("The display message indicating this is a rank question is displayed until all options are ranked",
                      "Please rank the above options.", submitPage.getRankMessage(1, 0));
        submitPage.selectResponseTextDropdown(1, 0, 1, "3");
        submitPage.selectResponseTextDropdown(1, 0, 2, "1");
        submitPage.selectResponseTextDropdown(1, 0, 3, "4");
        assertTrue("No error message expected", submitPage.getRankMessage(1, 0).isEmpty());
        
        submitPage.selectResponseTextDropdown(7, 0, 0, "4");
        submitPage.selectResponseTextDropdown(7, 0, 1, "3");
        submitPage.selectResponseTextDropdown(7, 0, 2, "2");
        submitPage.selectResponseTextDropdown(7, 0, 3, "1");
        assertTrue("No error message expected", submitPage.getRankMessage(7, 0).isEmpty());
        
        submitPage.clickSubmitButton();
        // Go back to submission page
        submitPage = loginToStudentFeedbackSubmitPage("alice.tmms@FRankUiT.CS4221", "student");
        // to verify that the question submit form with existing response works correctly
        submitPage.verifyHtmlMainContent("/studentFeedbackSubmitPageSuccessRank.html");
        
        ______TS("Rank : student results");

        studentResultsPage = loginToStudentFeedbackResultsPage("alice.tmms@FRankUiT.CS4221", "student");
        studentResultsPage.verifyHtmlMainContent("/studentFeedbackResultsPageRank.html");
        
    }
    
    
    @Test
    public void testInstructorSubmitAndResultsPage() {
        
        ______TS("Rank submission: input disabled for closed session");
        
        FeedbackSubmitPage submitPage = loginToInstructorFeedbackSubmitPage("instructor1", "closed");
        int qnNumber = 1;
        int responseNumber = 0;
        int rowNumber = 0;
        assertFalse(submitPage.isNamedElementEnabled(Const.ParamsNames.FEEDBACK_QUESTION_RANKOPTION + "-" 
                                                     + qnNumber + "-" + responseNumber + "-" + rowNumber));
        

        ______TS("Rank submission: test submission page if some students are not visible to the instructor");
        submitPage = loginToInstructorFeedbackSubmitPage("instructorhelper", "instructor");
        submitPage.verifyHtmlMainContent("/instructorFeedbackSubmitPageRankHelper.html");
        

        ______TS("Rank standard submission");
        
        submitPage = loginToInstructorFeedbackSubmitPage("instructor1", "instructor");
        submitPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankSubmission.html");
        
        submitPage.selectResponseTextDropdown(1, 0, 2, "2");
        submitPage.selectResponseTextDropdown(1, 0, 1, "1");
        submitPage.selectResponseTextDropdown(1, 0, 0, "3");
        assertTrue(submitPage.getRankMessage(1, 0).isEmpty());
        
        submitPage.selectRecipient(2, 0, "Emily F.");
        submitPage.selectResponseTextDropdown(2, 0, 13, "1");
        submitPage.selectResponseTextDropdown(2, 0, 1, "2");
        
        submitPage.selectRecipient(2, 1, "Alice Betsy");
        submitPage.selectResponseTextDropdown(2, 1, 11, "1");
        submitPage.selectResponseTextDropdown(2, 1, 1, "1");
        assertEquals("Testing duplicate rank for rank options",
                     "The same rank should not be given multiple times.", submitPage.getRankMessage(2, 1));
        submitPage.selectResponseTextDropdown(2, 1, 1, "2");
        
        submitPage.selectResponseTextDropdown(3, 0, 0, "1");
        submitPage.selectResponseTextDropdown(3, 3, 0, "2");
        
        submitPage.clickSubmitButton();
        
        
        ______TS("Rank instructor results : question");

        instructorResultsPage = loginToInstructorFeedbackResultsPageWithViewType("instructor1", "instructor", false, "question");
        instructorResultsPage.waitForPanelsToCollapse();
        
        instructorResultsPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankQuestionView.html");
        
        
        ______TS("Rank instructor results : Giver > Recipient > Question");
        instructorResultsPage = loginToInstructorFeedbackResultsPageWithViewType("instructor1", "instructor", false, "giver-recipient-question");
        instructorResultsPage.waitForPanelsToCollapse();
        instructorResultsPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankGRQView.html");
        
        ______TS("Rank instructor results : Giver > Question > Recipient");
        instructorResultsPage = loginToInstructorFeedbackResultsPageWithViewType("instructor1", "instructor", false, "giver-question-recipient");
        instructorResultsPage.waitForPanelsToCollapse();
        instructorResultsPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankGQRView.html");
        
        ______TS("Rank instructor results : Recipient > Giver > Question ");
        instructorResultsPage = loginToInstructorFeedbackResultsPageWithViewType("instructor1", "instructor", false, "recipient-question-giver");
        instructorResultsPage.waitForPanelsToCollapse();
        instructorResultsPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankRQGView.html");
        
        ______TS("Rank instructor results : Recipient > Question > Giver");
        instructorResultsPage = loginToInstructorFeedbackResultsPageWithViewType("instructor1", "instructor", false, "recipient-giver-question");
        instructorResultsPage.waitForPanelsToCollapse();
        instructorResultsPage.verifyHtmlMainContent("/instructorFeedbackResultsPageRankRGQView.html");
    }
    

    @Test
    public void testEditPage(){
        feedbackEditPage = getFeedbackEditPage();
        testNewQuestionFrame();
        testInputValidation();
        testCustomizeOptions();
        testAddQuestionAction();
        testEditQuestionAction();
        testDeleteQuestionAction();
    }
    
    
    public void testNewQuestionFrame() {
        testNewRankRecipientsQuestionFrame();
        feedbackEditPage.reloadPage();
        testNewRankOptionsQuestionFrame();
    }
    

    private void testNewRankRecipientsQuestionFrame() {
        ______TS("Rank recipients: new question (frame)");

        feedbackEditPage.selectNewQuestionType("Rank (recipients) question");
        feedbackEditPage.clickNewQuestionButton();
        assertTrue(feedbackEditPage.verifyNewRankRecipientsQuestionFormIsDisplayed());
    }
    
 
    private void testNewRankOptionsQuestionFrame() {
        ______TS("Rank options: new question (frame)");
        feedbackEditPage.selectNewQuestionType("Rank (options) question");
        feedbackEditPage.clickNewQuestionButton();
        assertTrue(feedbackEditPage.verifyNewRankOptionsQuestionFormIsDisplayed());
    }
    
    
    public void testInputValidation() {
        
        ______TS("Rank edit: empty question text");

        feedbackEditPage.clickAddQuestionButton();
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_TEXTINVALID, feedbackEditPage.getStatus());
    }
    
    
    @Override
    public void testCustomizeOptions() {
        // todo
    }
    

    public void testAddQuestionAction() {
        ______TS("Rank edit: add rank option question action success");
        
        assertNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 1));
        
        feedbackEditPage.fillQuestionBox("Rank qn");
        feedbackEditPage.fillRankOptionForNewQuestion(0, "Option 1 <>");
        
        assertEquals(2, feedbackEditPage.getNumOfOptionsInRankOptionsQuestion(-1));
        // try to submit with insufficient non-blank option
        feedbackEditPage.clickAddQuestionButton();
        assertEquals(FeedbackRankOptionsQuestionDetails.ERROR_NOT_ENOUGH_OPTIONS 
                     + FeedbackRankOptionsQuestionDetails.MIN_NUM_OF_OPTIONS + ".", 
                     feedbackEditPage.getStatus());
        
        
        feedbackEditPage.selectNewQuestionType("Rank (options) question");
        feedbackEditPage.clickNewQuestionButton();
        
        feedbackEditPage.fillQuestionBox("Rank qn");
        
        // blank option at the start and end, to check they are removed
        feedbackEditPage.clickAddMoreRankOptionLinkForNewQn();
        feedbackEditPage.fillRankOptionForNewQuestion(1, "Option 1 <>");
        feedbackEditPage.fillRankOptionForNewQuestion(2, "  Option 2  ");
        feedbackEditPage.clickAddMoreRankOptionLinkForNewQn(); 
        assertEquals(4, feedbackEditPage.getNumOfOptionsInRankOptionsQuestion(-1));
        
        feedbackEditPage.tickDuplicatesAllowedCheckboxForNewQuestion();
        
        feedbackEditPage.clickAddQuestionButton();
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_ADDED, feedbackEditPage.getStatus());
        assertNotNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 1));
        
        assertEquals("Blank options should have been removed", 2, feedbackEditPage.getNumOfOptionsInRankOptionsQuestion(1));
        
        ______TS("Rank edit: add rank recipient question action success");
        feedbackEditPage.selectNewQuestionType("Rank (recipients) question");
        feedbackEditPage.clickNewQuestionButton();
        
        assertNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 2));
        
        feedbackEditPage.verifyRankOptionIsHiddenForNewQuestion(0);
        feedbackEditPage.verifyRankOptionIsHiddenForNewQuestion(1);
        feedbackEditPage.fillQuestionBox("Rank recipients qn");
        
        feedbackEditPage.clickAddQuestionButton();
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_ADDED, feedbackEditPage.getStatus());
        assertNotNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 2));
        
        feedbackEditPage.verifyHtmlMainContent("/instructorFeedbackRankQuestionAddSuccess.html");
    }
    

    public void testEditQuestionAction() {
        ______TS("rank edit: edit rank options question success");
        assertTrue(feedbackEditPage.clickEditQuestionButton(1));
        
        // Verify that fields are editable
        feedbackEditPage.verifyHtmlPart(By.id("questionTable1"),
                                        "/instructorFeedbackRankQuestionEdit.html");
        
        feedbackEditPage.fillEditQuestionBox("edited Rank qn text", 1);

        feedbackEditPage.clickRemoveRankOptionLink(1, 0);
        assertEquals("Should still remain with 2 options,"
                         + "less than 2 options should not be permitted",
                     2, feedbackEditPage.getNumOfOptionsInRankOptionsQuestion(1));
        
        feedbackEditPage.fillRankOptionForQuestion(1, 1, " (Edited) Option 2 ");
        
        // Should end up with 4 choices, including (1) and (2)
        feedbackEditPage.clickAddMoreRankOptionLink(1);
        feedbackEditPage.clickAddMoreRankOptionLink(1);
        feedbackEditPage.fillRankOptionForQuestion(1, 2, "  <New> Option 3 ");
        feedbackEditPage.fillRankOptionForQuestion(1, 3, "Option 4 (slightly longer text for this one)");
        
        feedbackEditPage.untickDuplicatesAllowedCheckboxForQuestion(1);
        
        feedbackEditPage.clickSaveExistingQuestionButton(1);
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_EDITED, feedbackEditPage.getStatus());
        feedbackEditPage.verifyHtmlMainContent("/instructorFeedbackRankQuestionEditSuccess.html");

        ______TS("rank edit: edit rank recipients question success");
        assertTrue(feedbackEditPage.clickEditQuestionButton(2));
        
        feedbackEditPage.tickDuplicatesAllowedCheckboxForQuestion(2);
        feedbackEditPage.clickSaveExistingQuestionButton(2);
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_EDITED, feedbackEditPage.getStatus());
        assertTrue(feedbackEditPage.isRankDuplicatesAllowedChecked(2));
    }
    
    
    public void testDeleteQuestionAction() {
        ______TS("rank: qn delete");

        feedbackEditPage.clickAndConfirm(feedbackEditPage.getDeleteQuestionLink(2));
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_DELETED, feedbackEditPage.getStatus());
        assertNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 2));
        
        feedbackEditPage.clickAndConfirm(feedbackEditPage.getDeleteQuestionLink(1));
        assertEquals(Const.StatusMessages.FEEDBACK_QUESTION_DELETED, feedbackEditPage.getStatus());
        assertNull(BackDoor.getFeedbackQuestion(instructorCourseId, instructorEditFSName, 1));
    }
    
        
    private InstructorFeedbackEditPage getFeedbackEditPage() {
        AppUrl feedbackPageLink = createUrl(Const.ActionURIs.INSTRUCTOR_FEEDBACK_EDIT_PAGE)
                                        .withUserId(instructorId).withCourseId(instructorCourseId).withSessionName(instructorEditFSName);
        return loginAdminToPage(browser, feedbackPageLink, InstructorFeedbackEditPage.class);
    }
    
    
    private FeedbackSubmitPage loginToInstructorFeedbackSubmitPage(
            String instructorName, String fsName) {
        AppUrl submitPageUrl = createUrl(Const.ActionURIs.INSTRUCTOR_FEEDBACK_SUBMISSION_EDIT_PAGE)
                        .withUserId(testData.instructors.get(instructorName).googleId)
                        .withCourseId(testData.feedbackSessions.get(fsName).courseId)
                        .withSessionName(testData.feedbackSessions.get(fsName).feedbackSessionName);
        return loginAdminToPage(browser, submitPageUrl, FeedbackSubmitPage.class);
    }
    
    
    private FeedbackSubmitPage loginToStudentFeedbackSubmitPage(
            String studentName, String fsName) {
        AppUrl submitPageUrl = createUrl(Const.ActionURIs.STUDENT_FEEDBACK_SUBMISSION_EDIT_PAGE)
                        .withUserId(testData.students.get(studentName).googleId)
                        .withCourseId(testData.feedbackSessions.get(fsName).courseId)
                        .withSessionName(testData.feedbackSessions.get(fsName).feedbackSessionName);
        return loginAdminToPage(browser, submitPageUrl, FeedbackSubmitPage.class);
    }
    
    
    private StudentFeedbackResultsPage loginToStudentFeedbackResultsPage(
            String studentName, String fsName) {
        AppUrl resultsPageUrl = createUrl(Const.ActionURIs.STUDENT_FEEDBACK_RESULTS_PAGE)
                        .withUserId(testData.students.get(studentName).googleId)
                        .withCourseId(testData.feedbackSessions.get(fsName).courseId)
                        .withSessionName(testData.feedbackSessions.get(fsName).feedbackSessionName);
        return loginAdminToPage(browser, resultsPageUrl,
                StudentFeedbackResultsPage.class);
    }
    
    
    private InstructorFeedbackResultsPage loginToInstructorFeedbackResultsPageWithViewType(
            String instructorName, String fsName, boolean needAjax, String viewType) {
        AppUrl resultsPageUrl = createUrl(Const.ActionURIs.INSTRUCTOR_FEEDBACK_RESULTS_PAGE)
                    .withUserId(testData.instructors.get(instructorName).googleId)
                    .withCourseId(testData.feedbackSessions.get(fsName).courseId)
                    .withSessionName(testData.feedbackSessions.get(fsName).feedbackSessionName);
        
        if (needAjax){
            resultsPageUrl = resultsPageUrl.withParam(Const.ParamsNames.FEEDBACK_RESULTS_NEED_AJAX, String.valueOf(needAjax));
        }
        
        if (viewType != null){
            resultsPageUrl = resultsPageUrl.withParam(Const.ParamsNames.FEEDBACK_RESULTS_SORTTYPE, viewType);
        }
        
        return loginAdminToPage(browser, resultsPageUrl, InstructorFeedbackResultsPage.class);
    }
    
    
    private FeedbackQuestionSubmitPage loginToStudentFeedbackQuestionSubmitPage(
            String studentName, String fsName, String questionId) {
        StudentAttributes s = testData.students.get(studentName);
        AppUrl submitPageUrl = createUrl(Const.ActionURIs.STUDENT_FEEDBACK_QUESTION_SUBMISSION_EDIT_PAGE)
                            .withUserId(s.googleId)
                            .withCourseId(testData.feedbackSessions.get(fsName).courseId)
                            .withSessionName(testData.feedbackSessions.get(fsName).feedbackSessionName)
                            .withParam(Const.ParamsNames.FEEDBACK_QUESTION_ID, questionId);
        
        return loginAdminToPage(browser, submitPageUrl, FeedbackQuestionSubmitPage.class);
    }

    @AfterClass
    public static void classTearDown() throws Exception {
        BrowserPool.release(browser);
    }

}
