class AddClosedReasonToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :closed_reason, :string
  end
end
