$(function(){
    $('#activity_select').chosen({width: "95%"});

// Make the chosen drop-down dynamic. If a given option is not in the list, the user can still add it
    $('.chosen-choices .search-field input[type=text]').keydown(
        function (evt) {
            var stroke, _ref, target, list;
            stroke = (_ref = evt.which) != null ? _ref : evt.keyCode;
            // If enter or tab key
            if (stroke === 9 || stroke === 13) {
                target = $(evt.target);
                // get the list of current options
                chosenList = target.parents('.chosen-container').find('.chosen-choices li.search-choice > span').map(function () {
                    return $(this).text();
                }).get();
                // get the list of matches from the existing drop-down
                matchList = target.parents('.chosen-container').find('.chosen-results li').map(function () {
                    return $(this).text();
                }).get();
                // highlighted option
                highlightedList = target.parents('.chosen-container').find('.chosen-results li.highlighted').map(function () {
                    return $(this).text();
                }).get();
                // Get the value which the user has typed in
                var newString = $.trim(target.val());
                // if the option does not exists, and the text doesn't exactly match an existing option, and there is not an option highlighted in the list
                if ($.inArray(newString, matchList) < 0 && $.inArray(newString, chosenList) < 0 && highlightedList.length == 0) {
                    // Create a new option and add it to the list (but don't make it selected)
                    var newOption = '<option value="' + newString + '">' + newString + '</option>';
                    $("#activity_select").prepend(newOption);
                    // trigger the update event
                    $("#activity_select").trigger("chosen:updated");
                    // tell chosen to close the list box
                    $("#activity_select").trigger("chosen:close");
                    return true;
                }
                // otherwise, just let the event bubble up
                return true;
            }
        })
})