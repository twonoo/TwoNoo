class AddCampaignToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :campaign, :string
  end
end
