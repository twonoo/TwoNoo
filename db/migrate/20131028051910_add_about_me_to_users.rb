class AddAboutMeToUsers < ActiveRecord::Migration
  def change
      add_column :users, :AboutMe, :text
  end
end
