$(function(){
  $('#notifications_link').click(function(e) {
    console.log('notifications_link clicked');
    var $notifMenu = $('#notifications_menu');
    var isActive = $notifMenu.hasClass('open');
    if (!isActive)
    {
      $.ajax({
        url: "/notifications/display",
        datatype: 'html',
        cache: false,
         success: function(html) {
         console.log('got the notifs');
	   $('#notifications_dropdown').html(html);
         console.log('notifs displayed' + html);
	 }
      });
    }
  });

  $('#notifications_link_mobile').click(function(e) {
    console.log('notifications_link clicked');
    var $notifMenu = $('#alerts');
    var isActive = $notifMenu.hasClass('open');
    if (!isActive)
    {
      $.ajax({
        url: "/notifications/notifications_mobile",
        datatype: 'html',
        cache: false,
         success: function(html) {
           console.log('got the notifs');
           $('#notifications_dropdown_mobile').html(html);
           console.log('notifs displayed' + html);
	 }
      });
    }
  });

  var interval = 30000;   //number of mili seconds between each call
  var refresh_num_notifs = function() {
    $.ajax({
      url: "/notifications/number",
      datatype: 'script',
      cache: false,
      success: function(html) {
          $('#notifications_badge').html(html);
          $('#notifications_badge_mobile').html(html);

	setTimeout(function() {
	  refresh_num_notifs();
	}, interval);
      }
    });
  };

  setTimeout(function() {
    refresh_num_notifs();
  }, interval);

  $('#messages_link').click(function(e) {
    var $messagesMenu = $('#messages_menu');
    var isActive = $messagesMenu.hasClass('open');
    if (!isActive)
    {
      $.ajax({
        url: "/messages/display",
        datatype: 'html',
        cache: false,
         success: function(html) {
	   $('#messages_dropdown').html(html);
	 }
      });
    }
  });

  var refresh_num_messages = function() {
    $.ajax({
      url: "/messages/number",
      datatype: 'script',
      cache: false,
      success: function(html) {
	$('#messages_badge').html(html);

	setTimeout(function() {
	  refresh_num_messages();
	}, interval);
      }
    });
  };

  setTimeout(function() {
    refresh_num_messages();
  }, interval);
});
