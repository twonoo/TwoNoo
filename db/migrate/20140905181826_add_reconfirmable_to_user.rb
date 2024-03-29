class AddReconfirmableToUser < ActiveRecord::Migration
  # Note: You can't use change, as User.update_all with fail in the down migration
  def self.up
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
  end

  def self.down
     remove_columns :users, :unconfirmed_email # Only if using reconfirmable
  end
end
