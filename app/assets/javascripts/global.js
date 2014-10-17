$(document).ready(function(){
  $('a').bind('click', function(e){
    if ($(this).attr('clicked') == 'true'){
      e.preventDefault();
    }
    $(this).attr('clicked', 'true');
  });
});

