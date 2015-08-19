class AddCancelReasonToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :cancel_reason, :string
  end
end
