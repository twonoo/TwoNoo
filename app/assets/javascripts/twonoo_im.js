var interval = 30000; // 30 seconds
var channels = new Object();

$(document).ready(function() {
  init_im();
});

var Dispatcher = function(){
};

Dispatcher.supportsWebsockets = false;
Dispatcher.initialized = false;
Dispatcher.handle = false;
Dispatcher.init_dispatcher = function(){
  if (!(Dispatcher.initialized))
  {
    $(Dispatcher).bind('onopen onerror', function(){Dispatcher.initialized = true;});

    Dispatcher.dispatcher = new WebSocketRails('dev-steve.twonoo.com:3001/websocket');

    Dispatcher.dispatcher.on_open = function(data) {
      Dispatcher.supportsWebsockets = true;
      console.log('Connection has been established: ', data);
      // You can trigger new server events inside this callback if you wish.

      if (Dispatcher.handle) {
        cleearInterval(Dispatcher.handle);
        Dispatcher.handle = false;
      }

      $(Dispatcher).trigger('onopen',data);
    }

    Dispatcher.dispatcher.bind('connection_error', function(data) {
      Dispatcher.supportsWebsockets = false;
      console.log("connection error!", data) 

      $(Dispatcher).trigger('onerror',data);
    });

    Dispatcher.dispatcher.bind('connection_closed', function(data) {
      Dispatcher.supportsWebsockets = false;
      Dispatcher.initialized = false; /* reset to false so we can attempt to reinitialize at some point */
      console.log("connection closed!", data) 

      $(Dispatcher).trigger('onclose',data);
    });
  }
};

function init_im()
{
  /*$( ".draggable").draggable(); disabling because it's kinda funky on IE and safari */

  $('.messageMe').unbind('click');
  $('.messageMe').bind('click', function(e){
    $(this).next('.draggable').is(':visible')?  $(this).next('.draggable').hide(): $(this).next('.draggable').show();
    e.preventDefault();
  });

  Dispatcher.init_dispatcher();
  IM.init('.send_message');
  AIM.init('.send_activity_message');
  CIM.init('.send_conversation_message');
}

var IM = function(link){
  this.link = link;
  this.body = link.prev('.body');
  this.conversation = this.body.prev('.conversation');

  this.recipient_id = link.attr('recipient');
  this.recipient_name = link.attr('recipient_name');

  this.sender_id = link.attr('sender');
  this.sender_name = link.attr('sender_name');
  
  this.channelName = link.attr('sender') + '_' + link.attr('recipient');

  var m = this;
  this.body.keyup(function(e) {
    if (e.keyCode == 13 && !e.shiftKey) {
      e.preventDefault();
      m.link.trigger('click');
    }
    else if (e.keyCode == 27)
    {
      $(this).val('');
    }
  });

  this.link.unbind('click'); /* make sure there aren't any other click handlers */
  this.link.bind('click', function(e){
    m.send_message();
  });

  $(Dispatcher).bind('onclose onopen', function(data){
    /* reset the channels */
    console.log('the connection was closed. reset the channels and listeners');
    clearInterval(m.channel);
    m.channel = false;
    m.listen(); /* start the listeners back up - this might get a litte funky if the listener was never started */
  });
};

IM.init = function(selector){
  console.log("initializing IM messengers");
  IM.messengers = IM.messengers || new Object();

  $(selector).each(function(){
    if (!(IM.messengers[IM.channelName($(this))]))
    {
      var messenger = new IM($(this));
      IM.messengers[messenger.channelName] = messenger;
    }
  });
  
}

IM.channelName = function(link){
  return link.attr('sender') + '_' + link.attr('recipient');
};

IM.prototype.add_to_conversation = function(message, recipient) {
  console.log("add_to_conversation: ", message)
  message_row_template = '<div class="row" style="background-color:#EEEEEE;padding-top:0px;padding-bottom:0px;margin-top:0px;border-bottom-style:solid;border-bottom-width:thin;border-bottom-color:#DDDDDD;#{color};">';
  message_row_template += '<div class="col-xs-3" style="overflow:hidden;white-space: nowrap;"><b>#{name}</b></div><div class="col-xs-9" style="background-color:#FFFFFF">#{body}</div></div>';

  message_row = new Template(message_row_template);
  var body = message.body;
  var name = recipient?this.recipient_name:this.sender_name;
  var color = recipient?'color:#1111FF;':'';

  this.conversation.append(message_row.run({color: color, name: name, body: body}));
};

IM.prototype.clicked = function(clicked) {
  if (!(typeof clicked === "undefined"))
  {
    this.link.attr('clicked', clicked);    
  }

  return (this.link.attr('clicked') == 'true');
};

IM.prototype.listen = function(){
  if (Dispatcher.supportsWebsockets)
  {
    this.listen_websockets();
  }
  else
  {
    this.listen_polling();
  }
}

IM.prototype.listen_long_polling = function(){
  console.log("Long polling is not implemented yet.");
};

IM.prototype.listen_polling = function(){
  var m = this;
  if (!this.channel) { this.channel = setInterval(function(){m.refresh();}, interval); }
};

IM.prototype.listen_websockets = function(){
  console.log("do we have a channel?", this.channelName);
  if (!(this.channel))
  {
    var dispatcher = Dispatcher.dispatcher;
    console.log("binding channel", this.channelName);
    this.channel = dispatcher.subscribe(this.channelName);

    var m = this;
    this.channel.bind('new_message', function(data){
      console.log('Channel event received: ' + data.body);
      m.add_to_conversation(data, true);
    });
  }
};

IM.prototype.message_text = function() {
  return this.body.val();
};


IM.prototype.refresh = function()
{
  var checkTime = new Date(Date.now() - interval);
  console.log("checkTime: " , checkTime);
  console.log("checkTime: ", checkTime.toJSON());

  var message = {
    body: this.body.val(),
    recipient: this.sender_id,
    sender: this.recipient_id,
    check: checkTime.toJSON()
  };

  var m = this;

  $.ajax({
    type: "POST",
    dataType: 'json',
    url: "/conversations/new_messages",
    data: message,
    success: function(response) {
      for (var i = 0; i < response.length; i++)
      {
        m.add_to_conversation(response[i], true);
      }
    },
    error: function(response) {
      console.log("failure: ", response.message);
    }
  });
} /* END refresh_im */

IM.prototype.send_message = function()
{
  // Don't send the message until it is either successful or failed
  if (this.clicked() || (this.body.val().trim().length == 0)){ return; }
  this.toggle_sending(false);

  var message = {
    body: this.message_text(),
    recipient: this.recipient_id,
    sender: this.sender_id
  };

  if (Dispatcher.supportsWebsockets)
  {
    this.send_websocket(message);
  }
  else
  {
    /* We don't support websockets so we are going to do this old school */
    this.send_ajax(message);
  }

}; /* END send_message */

IM.prototype.send_ajax = function(message){
  var m = this;
  $.ajax({
    type: "POST",
    dataType: "json",
    url: "/conversations/send_message",
    data: message,
    success: function(response) {
      m.add_to_conversation(message, false);
      m.toggle_sending(true);
      console.log("success: ", response);

      m.listen();
    },
    error: function(response) {
      m.toggle_sending(false);
      console.log("failure: ", response);
    }
  });
}; /* END send_ajax */

IM.prototype.send_websocket = function(message){
  var m = this;
  var dispatcher = Dispatcher.dispatcher;

  // Send the message to the server to be sent to the other user
  dispatcher.trigger(
    'send_message',
    message,
    function(response){
      m.add_to_conversation(message, false);
      m.toggle_sending(true);
      console.log("success: ", response);

      m.listen();
    },
    function(response){
      m.toggle_sending(false);
      console.log("failure: ", response);
    }
  );
}; /* END send_websocket */

IM.prototype.toggle_sending = function(clearText)
{
  if (this.clicked())
  {
    this.clicked('false');    
    this.body.prop('disabled', false);
    this.body.focus();

    if (clearText) { this.body.val(''); }

    this.link.html('SEND MESSAGE');
  }
  else
  {
    this.clicked('true');
    this.body.prop('disabled', true);
    this.link.html('SENDING MESSAGE...');
  }
}; /* END toggle_sending */


var AIM = function(link){
  IM.call(this, link);

  this.activity_name = link.attr('activity_name');
};

AIM.prototype = Object.create(IM.prototype);

AIM.init = function(selector){
  console.log("initializing AIM messengers");
  AIM.messengers = AIM.messengers || new Object();

  $(selector).each(function(){
    var messenger = new AIM($(this));
    AIM.messengers[messenger.channelName] = messenger;
  });
};

AIM.prototype.message_text = function(){
  return this.body.val() + ' - (Sent from: ' + this.activity_name + ')';
};

var CIM = function(link){
  IM.call(this, link);

  this.conversation = $('#conversation');
};

CIM.prototype = Object.create(IM.prototype);

CIM.init = function(selector){
  console.log("initializing CIM messengers");
  CIM.messengers = CIM.messengers || new Object();


  $(selector).each(function(){
    var messenger = new CIM($(this));
    CIM.messengers[messenger.channelName] = messenger;

    if (!(Dispatcher.initialized))
    { /* wait until it finished initializing to start listening */
      $(Dispatcher).bind('onopen onerror', function(data){
        messenger.listen();
      });
    }
    else
    {
      messenger.listen();
    }
  });
};

CIM.prototype.add_to_conversation = function(message, recipient) {
  console.log("add_to_conversation: ", message)
  message_row_template = '<div class="row" style="background-color:#EEEEEE;padding-top:0px;padding-bottom:0px;margin-top:0px;border-bottom-style:solid;border-bottom-width:thin;border-bottom-color:#DDDDDD;#{color};">';
  message_row_template += '<div class="col-xs-3" style="overflow:hidden;white-space: nowrap;"><b>#{name}</b></div><div class="col-xs-9" style="background-color:#FFFFFF">#{body}</div></div>';
    /*
  if (message.created_at < (Date.now() - 1.day))
  {
    message_row_template += <span style="font-size:50%;">(message.created_at.strftime("%m/%d"))</span>
  }
  else
  {
    message_row_template += <span style="font-size:50%;">(message.created_at.strftime("%l:%M %P"))</span>
  }
  */

  message_row = new Template(message_row_template);
  var body = message.body;
  var name = recipient?this.recipient_name:this.sender_name;
  var color = recipient?'color:#1111FF;':'';

  this.conversation.prepend(message_row.run({color: color, name: name, body: body}));
};

var Template = function(t){
  this.t = t
}

Template.prototype.run = function(attrs){
  var str = this.t;
  for (attr in attrs) {
    str = str.replace('#{' + attr + '}', attrs[attr]);
  }
  return str;
}; /* END run */
