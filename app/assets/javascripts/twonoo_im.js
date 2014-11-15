function init_im(){
    var dispatcher = new WebSocketRails('dev-steve.twonoo.com:3001/websocket');
    var channels = new Object();

    dispatcher.on_open = function(data) {
      console.log('Connection has been established: ', data);
      // You can trigger new server events inside this callback if you wish.
    }

    $('.body').keyup(function(e) {
      if (e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault();
        $(this).next('.send_message').trigger("click");
      }
      else if (e.keyCode == 27)
      {
        $(this).val('');
      }
    });

    $('.send_message').unbind('click');
    $('.send_message').bind('click', function(e){
      if ($(this).attr('clicked') == 'true'){
        e.preventDefault();
      }
      else {
        sendMessage_im($(this));
      }

      $(this).attr('clicked', 'true');
    });

    var sendMessage_im = function(link) {
      link.html('SENDING MESSAGE...');
      var conversation = link.prev('.body').prev('.conversation');

      channelName = link.attr('sender') + '_' + link.attr('recipient')

      var channel = channels[channelName];

      if (!channel)
      {
        channel = channels[channelName] = dispatcher.subscribe(channelName);
  
        channel.bind('new_message', function(data){
          console.log('Channel event received: ' + data.body);
          conversation.append('<div class="row" style="background-color:#EEEEEE;padding-top:0px;padding-bottom:0px;margin-top:0px;border-bottom-style:solid;border-bottom-width:thin;border-bottom-color:#DDDDDD;color:#1111FF;">'
          + '<div class="col-xs-3" style="overflow:hidden;white-space: nowrap;">'
          + '<b>' + link.attr('recipient_name' ) + '</b></div><div class="col-xs-9" style="background-color:#FFFFFF">'
          + data.body
          + '</div></div>');
          conversation.animate({scrollTop: conversation.prop('scrollHeight')}, 3000);
        });
      }

      var message = {
        body: link.prev().val(),
        recipient: link.attr('recipient'),
        sender: link.attr('sender')
      };

      conversation.append('<div class="row" style="background-color:#EEEEEE;padding-top:0px;padding-bottom:0px;margin-top:0px;border-bottom-style:solid;border-bottom-width:thin;border-bottom-color:#DDDDDD;">'
      + '<div class="col-xs-3" style="overflow:hidden;white-space: nowrap;">'
      + '<b>' + link.attr('sender_name' ) + '</b></div><div class="col-xs-9" style="background-color:#FFFFFF">'
      + message.body
      + '</div></div>');
      conversation.animate({scrollTop: conversation.prop('scrollHeight')}, 3000);

      dispatcher.trigger(
        'send_message',
        message,
        function(){
          console.log("success: ");
          link.attr('clicked', 'false');    
          link.prev('.body').val('');
          link.html('SEND MESSAGE');
        },
        function(response){
          console.log("failure: " + response.message);
          link.attr('clicked', 'false');    
        }
      );
    };
}
