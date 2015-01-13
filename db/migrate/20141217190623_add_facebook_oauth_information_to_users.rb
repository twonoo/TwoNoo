class AddFacebookOauthInformationToUsers < ActiveRecord::Migration
  def change

    add_column :users, :fb_token, :string, limit: 500
    add_column :users, :fb_token_expires_in, :integer

  end
end
