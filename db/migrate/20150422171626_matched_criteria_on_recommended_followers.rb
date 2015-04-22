class MatchedCriteriaOnRecommendedFollowers < ActiveRecord::Migration
  def change

    add_column :recommended_followers, :match_criteria, :string
    add_column :recommended_followers, :match_data, :string

    #backfill match_criteria
    RecommendedFollower.all.each do |rf|
      case rf.order
        when 1
          rf.update_attribute(:match_criteria, "You're facebook friends")
        when 2
          rf.update_attribute(:match_criteria, "They're following you")
        when 3
          rf.update_attribute(:match_criteria, "You're following several of the same people")
        when 4
          rf.update_attribute(:match_criteria, "You're at the same level")
      end
    end

  end
end
