class AddTokenAndRefreshTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gcal_token, :string
    add_column :users, :gcal_token_issued_at, :datetime
    add_column :users, :gcal_token_expires_in, :integer
    add_column :users, :gcal_refresh_token, :string
  end
end
