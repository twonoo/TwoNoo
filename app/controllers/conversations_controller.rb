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
      if (c.originator.id = current_user.id) || (c.recipients.first.id = recipient.id) then
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

    redirect_to conversation_path(conversation)
  end

  def reply
    current_user.reply_to_conversation(conversation, *message_params(:body))
    redirect_to conversation_path(conversation)
  end

  def show
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

