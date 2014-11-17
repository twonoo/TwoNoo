var interval = 30000; // 30 seconds
var channels = new Object();
var supportsWebsockets = false;
var dispatcher;

function init_im()
{
    dispatcher = new WebSocketRails('dev-steve.twonoo.com:3001/websocket');

    dispatcher.on_open = function(data) {
      console.log('Connection has been established: ', data);
      // You can trigger new server events inside this callback if you wish.

      supportsWebsockets = true;
    }
    
    dispatcher.on_error = function(data) {
      console.log('Unable to establish connection: ', data);
      supportsWebsockets = false;
    }

    init_send_message();

}

function append_to_conversation(conversation, name, message, recipient)
{
    message_row = '<div class="row" style="background-color:#EEEEEE;padding-top:0px;padding-bottom:0px;margin-top:0px;border-bottom-style:solid;border-bottom-width:thin;border-bottom-color:#DDDDDD;';
    if (recipient) { message_row += 'color:#1111FF;'; }
    message_row += '">';
    message_row += '<div class="col-xs-3" style="overflow:hidden;white-space: nowrap;">'
      + '<b>' + name + '</b></div><div class="col-xs-9" style="background-color:#FFFFFF">'
      + message
      + '</div></div>'

    conversation.append(message_row);
    conversation.animate({scrollTop: conversation.prop('scrollHeight')}, 500);
} // END append_to_conversation

function init_send_message()
{
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
    sendMessage_im($(this));
  });
}

function refresh_im(conversation, link)
{

  var checkTime = new Date(Date.now() - interval);
  console.log("checkTime: " , checkTime);
  console.log("checkTime: ", checkTime.toJSON());

  var message = {
    body: link.prev().val(),
    recipient: link.attr('sender'),
    sender: link.attr('recipient'),
    check: checkTime.toJSON()
  };

  $.ajax({
    type: "POST",
    dataType: 'json',
    url: "/conversations/new_messages",
    data: message,
    success: function(response) {
      for (var i = 0; i < response.length; i++)
      {
        append_to_conversation(conversation, link.attr('recipient_name'), response[i].body, true);
      }
    },
    error: function(response) {
      console.log("failure: ", response.message);
    }
  });
} // END refresh_im

function sendMessage_im(link)
{
  // Don't send the message until it is either successful or failed
  if ((link.attr('clicked') == 'true') || (link.prev('.body').val().trim().length == 0)){ return; }

  toggle_sending(link, false);

  var conversation = link.prev('.body').prev('.conversation');

  var message = {
    body: link.prev().val(),
    recipient: link.attr('recipient'),
    sender: link.attr('sender')
  };

  channelName = link.attr('sender') + '_' + link.attr('recipient')

  var channel = channels[channelName];

  if (supportsWebsockets && dispatcher)
  {
    // Send the message to the server to be sent to the other user
    dispatcher.trigger(
      'send_message',
      message,
      function(response){
        append_to_conversation(conversation, link.attr('sender_name'), message.body, false);

        toggle_sending(link, true);

        console.log("success: " + response.message);
      },
      function(response){
        toggle_sending(link, false);

        console.log("failure: " + response.message);
      }
    );

    // If we haven't already then open a channel to listen for a response
    if (!channel)
    {
      channel = channels[channelName] = dispatcher.subscribe(channelName);

      channel.bind('new_message', function(data){
        console.log('Channel event received: ' + data.body);
        append_to_conversation(conversation, link.attr('recipient_name'), data.body, true);
      });
    }
  }
  else
  {
    // We don't support websockets so we are going to do this old school
    $.ajax({
      type: "POST",
      dataType: "json",
      url: "/conversations/send_message",
      data: message,
      success: function(response) {
        append_to_conversation(conversation, link.attr('sender_name'), message.body, false);

        toggle_sending(link, true);

        console.log("success: " + response.message);

        // start polling for responses
        if (!channel) { channels[channelName] = setInterval(function(){refresh_im(conversation, link);}, interval); }
      },
      error: function(response) {
        toggle_sending(link, false);

        console.log("failure: ", response.message);
      }
    });
  }

} // END sendmessage_im

function toggle_sending(link, clearText)
{
  if (link.attr('clicked') == 'true')
  {
    link.attr('clicked', 'false');    
    link.prev('.body').prop('disabled', false);
    link.prev('.body').focus();

    if (clearText) { link.prev('.body').val(''); }

    link.html('SEND MESSAGE');
  }
  else
  {
    link.attr('clicked', 'true');
    link.prev('.body').prop('disabled', true);
    link.html('SENDING MESSAGE...');
  }
} // END toggle_sending
