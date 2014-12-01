class ConversationsController < ApplicationController

  before_filter :authenticate_user!
  helper_method :mailbox, :conversation

  def create
    recipient_emails = conversation_params(:recipients).split(',')
    recipients = User.where(email: recipient_emails).all
    recipient = User.where(email: recipient_emails).first

    # @receipts = mailbox.receipts.find_by!(:receiver_id => '3')
    @conversations = mailbox.conversations
    conversation = nil

    @conversations.each do |c|
      if (((c.originator.id == current_user.id) && (c.recipients.first.id == recipient.id)) || ((c.originator.id == recipient.id) && (c.recipients.first.id == current_user.id))) then
        conversation = c
        break
      end
    end

    if conversation.nil? then
      conversation = current_user.
        send_message(recipients, *conversation_params(:body), current_user.email).conversation
    else
      current_user.reply_to_conversation(conversation, *conversation_params(:body))
    end

    UserMailer.delay.new_message(recipient, current_user, *conversation_params(:body))

    redirect_to conversation_path(conversation)
  end

  def display_conversation
    respond_to do |format|
      format.js
    end
  end

  def load_earlier_messages
    respond_to do |format|
      format.html { render :partial => 'conversation', :locals => { :conversation => conversation } }
    end
  end

  def new_messages
    logger.info "new_messages"
    respond_to do |format|
      format.json do
        logger.info ""
        # get all of the messages sent to the user since check time
        recipient_id = params[:recipient]
        logger.info "recipient_id: #{recipient_id}"

        sender_id = params[:sender]
        logger.info "sender_id: #{sender_id}"

        recipient = User.find(recipient_id)
        sender = User.find(sender_id)

        @conversations = mailbox.conversations
        conv = nil

        @conversations.each do |c|
          next if c.originator.nil? || c.recipients.first.nil?
          if (((c.originator.id == sender.id) && (c.recipients.first.id == recipient.id)) || ((c.originator.id == recipient.id) && (c.recipients.first.id == sender.id))) then
            conv = c
            break
          end
        end

        r = []
        orderBy = "id ASC"
        conv.receipts_for(sender).where("mailboxer_receipts.created_at > '#{params[:check]}'").order(orderBy).each do |receipt|
          logger.info "message.sender.id: #{receipt.message.sender.id}"
          unless recipient == receipt.message.sender
            r << {body: receipt.message.body }
          end
        end
        
        render text: r.to_json
      end
    end
  end

  def send_message
    recipient = nil
    sender = nil
    respond_to do |format|
      format.html do
        logger.info "send_message html format"
        recipient = User.where(email: params[:recipient]).first
        sender - current_user

        message = {body: params[:body]}
        WebsocketRails["#{recipient.id}_#{current_user.id}"].trigger('new_message', message.to_json)

        logger.info("recipient: " + params[:recipient])

        logger.info recipient.email
        @conversations = mailbox.conversations
        conversation = nil

        @conversations.each do |c|
          next if c.originator.nil? || c.recipients.first.nil?
          if (((c.originator.id == current_user.id) && (c.recipients.first.id == recipient.id)) || ((c.originator.id == recipient.id) && (c.recipients.first.id == current_user.id))) then
            conversation = c
            break
          end
        end

        if conversation.nil? then
          conversation = current_user.
            send_message(recipient, *params[:body], current_user.email).conversation
        else
          current_user.reply_to_conversation(conversation, *params[:body])
        end
      end
      format.json do
        recipient_id = params[:recipient]
        logger.info "recipient_id: #{recipient_id}"

        sender_id = params[:sender]
        logger.info "sender_id: #{sender_id}"

        recipient = User.find(recipient_id)
        sender = User.find(sender_id)

        logger.info "Let the other person see the message"

        # Evenb though we are doing an ajax post the person listening might be using websockets
        WebsocketRails["#{recipient_id}_#{sender_id}"].trigger('new_message', params.to_json)

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
          conversation = sender.
            send_message(recipient, params[:body], sender.email).conversation
        else
          sender.reply_to_conversation(conversation, params[:body])
        end
        logger.info "return value"

        render text: "success".to_json
      end
    end

    UserMailer.delay.new_message(recipient, sender, *params[:body])
  end

  def show
    redirect_to conversations_path(:id => conversation.id)
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to :conversations
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :conversations
  end

  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
  end

  def fetch_params(key, *subkeys)
    params[key].instance_eval do
      case subkeys.size
      when 0 then self
      when 1 then self[subkeys.first]
      else subkeys.map{|k| self[k] }
      end
    end
  end
end

