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
      format.html { render :partial => 'load_earlier_messages', :locals => { :conversation => conversation } }
    end
  end

  def reply
    current_user.reply_to_conversation(conversation, params[:message_body])

    if conversation.originator == current_user
      recipient = conversation.recipients[0]
    else
      recipient = conversation.originator
    end

    respond_to do |format|
      format.html { render :partial => 'recent_messages', :locals => { :conversation => conversation } }
    end

    UserMailer.delay.new_message(recipient, current_user, params[:message_body])
  end

  def send_message
    recipient = User.where(email: params[:recipient]).first

    message = {body: params[:body]}
    WebsocketRails["#{recipient.id}_#{current_user.id}"].trigger('new_message', message)

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

    respond_to do |format|
      format.html { render :partial => '/conversations/recent_messages', :locals => { :conversation => conversation } }
    end

    UserMailer.delay.new_message(recipient, current_user, *params[:body])
  end

  def show
    redirect_to conversations_path(:id => conversation.id)
  end

  def show_messages
    respond_to do |format|
      format.html { render :partial => 'recent_messages', :locals => { :conversation => conversation } }
    end
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

