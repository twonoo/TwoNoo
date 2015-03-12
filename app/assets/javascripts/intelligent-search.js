substringMatcher = function (strs, limit) {
    return function findMatches(q, cb) {
        var matches, substrRegex;
        matches = [];
        substrRegex = new RegExp(q, 'i');

        $.each(strs, function (i, str) {
            if (substrRegex.test(str)) {
                // the typeahead jQuery plugin expects suggestions to a
                // JavaScript object, refer to typeahead docs for more info
                matches.push({ value: str });
            }
        });

        if(limit != null){
            matches = matches.slice(0, limit - 1);
        }

        cb(matches);
    };
};

function setupSuggestedSearch(terms) {
    if (terms && terms.length > 0) {
        $('#terms').typeahead(
            {
                hint: true,
                highlight: true,
                minLength: 1
            },
            {
                name: 'interests',
                displayKey: 'value',
                source: substringMatcher(terms, 8)
            }
        ).on('typehead:selected',function () {
                $('.typeahead').typeahead('close');
            }
        ).on('typeahead:autocompleted', function () {
                $('.typeahead').typeahead('close');
            }
        );
    }
}

function setupCitySuggestedSearch(terms, hint) {
    if (terms && terms.length > 0) {
        $('#location').typeahead(
            {
                hint: hint == null ? true : hint,
                highlight: true,
                minLength: 2
            },
            {
                name: 'cities',
                displayKey: 'value',
                source: substringMatcher(terms, 5)
            }
        ).on('typehead:selected',function () {
                $('.typeahead').typeahead('close');
            }
        ).on('typeahead:autocompleted', function () {
                $('.typeahead').typeahead('close');
            }
        );
    }
}

function setupNeighborhoodSearch(terms, hint) {
    if (terms && terms.length > 0) {
        $('#neighborhood').typeahead(
            {
                hint: hint == null ? true : hint,
                highlight: true,
                minLength: 2
            },
            {
                name: 'neighborhoods',
                displayKey: 'value',
                source: substringMatcher(terms, 5)
            }
        ).on('typehead:selected',function () {
                $('.typeahead').typeahead('close');
            }
        ).on('typeahead:autocompleted', function () {
                $('.typeahead').typeahead('close');
            }
        );
    }
}

//var suggestedSearchTerms = null;
//var searchInputLength = 0;
//
//var populateSearchDelay = (function () {
//    var timer = 0;
//    return function (callback, ms) {
//        clearTimeout(timer);
//        timer = setTimeout(callback, ms);
//    };
//})();
//
//function selectPartOfInput(element, startPos, endPos) {
//    if (typeof element.selectionStart != "undefined") {
//        element.selectionStart = startPos;
//        element.selectionEnd = endPos;
//    } else if (document.selection && document.selection.createRange) {
//        //For IE
//
//        element.focus();
//        element.select();
//        var r = document.selection.createRange();
//        r.moveEnd("character", endPos);
//        r.moveStart("character", startPos);
//        r.select();
//    }
//}
//
//function populateSearch() {
//    var re = new RegExp("," + $("#terms").attr("value"), "ig");
//    var pos = suggestedSearchTerms.search(re);
//
//    if (pos != -1) {
//        var match = suggestedSearchTerms.slice(pos + 1, suggestedSearchTerms.indexOf(",", pos + 1));
//        $("#terms").attr("value", match).select();
//        selectPartOfInput($("#terms")[0], searchInputLength, match.length);
//    }
//}
//
//function setupSuggestedSearch(terms, timeout) {
//    suggestedSearchTerms = terms;
//
//    if (suggestedSearchTerms && suggestedSearchTerms.length > 0) {
//        console.log('here');
//        $("#terms").keyup(function (e) {
//            console.log(e.keyCode);
//            if ((e.keyCode >= 48 && e.keyCode <= 90) || (e.keyCode >= 93 && e.keyCode <= 111) || e.keyCode >= 186) {
//                searchInputLength++;
//                populateSearchDelay(function () {
//                    populateSearch();
//                }, timeout);
//
//            } else if (e.keyCode == 8 || e.keyCode == 46) {
//                searchInputLength = $(this).attr("value").length
//            }
//        });
//    }
//}