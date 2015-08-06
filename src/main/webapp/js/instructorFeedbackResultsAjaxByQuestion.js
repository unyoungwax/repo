$(document).ready(function() {
    var seeMoreRequest = function(e) {
        var panelHeading = $(this);
        if ($('#show-stats-checkbox').is(':checked')) {
            $(panelHeading).find('[id^="showStats-"]').val('on');
        } else {
            $(panelHeading).find('[id^="showStats-"]').val('off');
        }

        var displayIcon = $(this).find('.display-icon');
        var formObject = $(this).children('form');
        var panelCollapse = $(this).parent().children('.panel-collapse');
        var panelBody = $(panelCollapse[0]).children('.panel-body');
        var formData = formObject.serialize();
        e.preventDefault();
        $.ajax({
            type: 'POST',
            cache: false,
            url: $(formObject[0]).attr('action') + '?' + formData,
            beforeSend: function() {
                displayIcon.html('<img height="25" width="25" src="/images/ajax-preload.gif">');
            },
            error: function() {

            },
            success: function(data) {
                var appendedQuestion = $(data).find('#questionBody-0').html();
                $(data).remove();
                if (typeof appendedQuestion != 'undefined') {
                    if (appendedQuestion.indexOf('resultStatistics') == -1) {
                        $(panelBody[0]).removeClass('padding-0');
                    }
                    $(panelBody[0]).html(appendedQuestion);
                } else {
                    $(panelBody[0]).removeClass('padding-0');
                    $(panelBody[0]).html('There are too many responses for this question. Please view the responses one section at a time.');
                }
                
                bindErrorImages($(panelBody[0]).find('.profile-pic-icon-hover, .profile-pic-icon-click'));
                // bind the show picture onclick events
                bindStudentPhotoLink($(panelBody[0]).find('.profile-pic-icon-click > .student-profile-pic-view-link'));
                // bind the show picture onhover events
                bindStudentPhotoHoverLink($(panelBody[0]).find('.profile-pic-icon-hover'));

                $(panelHeading).removeClass('ajax_submit');
                $(panelHeading).off('click');
                displayIcon.html('<span class="glyphicon glyphicon-chevron-down pull-right"></span>');
                $(panelHeading).click(toggleSingleCollapse);
                $(panelHeading).trigger('click');
                showHideStats();

            }
        });
    };

    // .ajax_submit is for loading a question's table by ajax if there are too many responses
    $('.ajax_submit').click(seeMoreRequest);

    // load missing responses is to reload a question table, but with the missing responses shown this time
    $('[id^=seeMissingResponses]').submit(loadMissingResponsesSubmitHandler);
});

/**
 * Event handler for submitting the form to reload the question table with missing responses shown
 * this should be bound to the form element
 */
function loadMissingResponsesSubmitHandler(e) {
    e.preventDefault();

    var submitButton = $(this).find('[id^=missingResponsesButton-]');

    var panel = $(this).closest('.panel');
    var panelBody = panel.find('.panel-body');

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: $(this).serialize(),
        beforeSend: function() {
            // removes the button 
            submitButton.html('<img height="25" width="25" src="/images/ajax-preload.gif">');
            console.log(submitButton);
        },
        error: function() {
            // TODO handle error
        },
        success: function(data) {
            var appendedQuestion = $(data).find('#questionBody-0').html();
            
            if (typeof appendedQuestion !== 'undefined') {
                $(panelBody).html(appendedQuestion);

                bindErrorImages(panelBody.find('.profile-pic-icon-hover, .profile-pic-icon-click'));
                // bind the show picture onclick events
                bindStudentPhotoLink(panelBody.find('.profile-pic-icon-click > .student-profile-pic-view-link'));
                // bind the show picture onhover events
                bindStudentPhotoHoverLink(panelBody.find('.profile-pic-icon-hover'));

                showHideStats();

                submitButton.hide();
            } else {
                // TODO: make a status message div to display error messages
                submitButton.html('There are too many responses for this question. Please view the responses one section at a time.');
            }
            
        }
    });
}
