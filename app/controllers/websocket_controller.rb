class WebsocketController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    controller_store[:message_count] = 0
  end

  def connected
    logger.info "user connected"
    logger.info message
  end

  def send_message
    logger.info "send_message"
    logger.info message

    recipient_id = message[:recipient]
    logger.info "recipient_id: #{recipient_id}"

    sender_id = message[:sender]
    logger.info "sender_id: #{sender_id}"

    recipient = User.find(recipient_id)
    sender = User.find(sender_id)

    logger.info "Let the other person see the message"

    Fiber.new do
      WebsocketRails["#{recipient_id}_#{sender_id}"].trigger('new_message', message)
    end.resume

    logger.info "Here we be"

    logger.info "email: #{recipient.email}"
    @conversations = sender.mailbox.conversations
    conversation = nil

    logger.info "Is this a new conv"
    @conversations.each do |c|
      next if c.originator.nil? || c.recipients.first.nil?
      if (((c.originator.id == sender.id) && (c.recipients.first.id == recipient.id)) || ((c.originator.id == recipient.id) && (c.recipients.first.id == sender.id))) then
        conversation = c
        break
      end
    end

    logger.info "record is"
    if conversation.nil? then
      conversation = sender.send_message(recipient, message[:body], sender.email).conversation
    else
      sender.reply_to_conversation(conversation, message[:body])
    end

    logger.info "mail it"
    UserMailer.delay.new_message(recipient, sender, message[:body])

    trigger_success

  end
end
