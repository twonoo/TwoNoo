class MatchedCriteriaOnRecommendedFollowers < ActiveRecord::Migration
  def change

    add_column :recommended_followers, :match_criteria, :string
    add_column :recommended_followers, :match_data, :string

    #backfill match_criteria
    RecommendedFollower.all.each do |rf|
      case rf.order
        when 1
          puts rf.update_attribute(:match_criteria, "You're facebook friends")
        when 2
‹››
        when 3
          puts rf.update_attribute(:match_criteria, "They're following you")
        when 4
          puts rf.update_attribute(:match_criteria, "You're at the same level")
      end
    end

  end
end
