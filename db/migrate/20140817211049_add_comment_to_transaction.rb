class AddCommentToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :comment, :text
  end
end
