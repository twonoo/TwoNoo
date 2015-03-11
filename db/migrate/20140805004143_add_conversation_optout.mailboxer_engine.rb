# This migration comes from mailboxer_engine (originally 20131206080416)
class AddConversationOptout < ActiveRecord::Migration
  def self.up
    create_table :mailboxer_conversation_opt_outs do |t|
      t.references :unsubscriber, :polymorphic => true
      t.references :conversation
    end
    add_foreign_key :mailboxer_conversation_opt_outs, :mailboxer_conversations, column: :conversation_id, primary_key: :id
  end

  def self.down
    remove_foreign_key :mailboxer_conversation_opt_outs, column: :conversation_id
    drop_table :mailboxer_conversation_opt_outs
  end
end
