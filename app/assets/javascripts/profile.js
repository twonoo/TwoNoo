$(document).ready(function() {
  $('.js-show-close-account-modal').on('click', function(e) {
    $('.js-close-account-modal').removeClass('hidden');
    $('input#other_reason').focus();
    e.preventDefault();
  });

  $('.remove-close-account-modal').on('click', function(e) {
    $('.js-close-account-modal').addClass('hidden');
    e.preventDefault();
  });

  $('#other_reason').keyup(function() {
    $("#profile_closed_reason").val($(this).val())
  });
});
