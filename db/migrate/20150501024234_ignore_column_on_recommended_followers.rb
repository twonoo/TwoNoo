class IgnoreColumnOnRecommendedFollowers < ActiveRecord::Migration
  def change

    add_column :recommended_followers, :ignored, :boolean, default: false

  end
end
