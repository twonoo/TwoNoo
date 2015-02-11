class CreateInterests < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do

      create_table :interests do |t|
        t.string :name, null: false
        t.string :code, null: false
        t.boolean :active, null: false, default: true
      end

      create_table :interests_options do |t|
        t.integer :interest_id, null: false
        t.string :option_name, null: false
        t.string :option_value
        t.string :code, null: false
        t.boolean :active, null: false, default: true
      end

      create_table :interests_users, id: false do |t|
        t.integer :user_id, null: false
        t.integer :interest_id, null: false
        t.integer :interests_option_id
      end

      create_table :view_logs do |t|
        t.integer :user_id
        t.string :view_name
      end

      interests = ['Art', 'Basketball', 'Billiards/Pool', 'Board Games', 'Book Club', 'Bowling', 'Brewing', 'Camping', 'Comedy', 'Concerts', 'Conversation', 'Cooking', 'Cornhole', 'Crafts', 'Cycling - Mountain Biking', 'Cycling - Road', 'Dancing', 'Darts', 'Dodgeball', 'Drinking', 'Fishing', 'Flag Football', 'Frisbee', 'Gardening', 'Golf', 'Hiking', 'Hockey', 'Hunting', 'Improv', 'Kickball', 'Movies', 'New/Expecting Moms', 'Painting', 'Pet Activities', 'Pickleball', 'Play dates', 'Playing cards', 'Politics', 'Racquetball', 'Running', 'Singles', 'Skiing - Cross Country', 'Skiing - Downhill', 'Snowboarding', 'Snowshoeing', 'Soccer', 'Softball', 'Spirituality', 'Tennis', 'Theater', 'Video Games', 'Volleyball', 'Volunteering', 'Walking', 'Weightlifting', 'Wine Tasting', 'Yoga']
      interests_options = {
          soccer: ['Preferred Position', 'Goalkeeper', 'Defender', 'Midfielder', 'Attacker'],
          hockey: ['Preferred Position', 'Goalkeeper', 'Defenseman', 'Right Wing', 'Left Wing', 'Center'],
          golf: ['Handicap', '-5 or lower', '+7 to -4', '+16 to +8', '+17 or higher'],
          running: ['Pace', 'Sub 5:00 min/mile', '5:00 - 6:00 min/mile', '6:00 - 7:00 min/mile', '7:00 - 8:00 min/mile', '8:00 - 9:00 min/mile', '9:00 - 10:00 min/mile', '10:00 - 11:00 min/mile', '11:00 - 12:00 min/mile', '12:00+ min/mile'],
          softball: ['Preferred Position', 'Pitcher', 'Catcher', 'First Base', 'Shortstop', 'Second Base', 'Third Base', 'Outfield'],
          tennis: ['USTA Rating', '1.5 - New to tennis', '2.0 - Learning Basics', '2.5 - Ready for Social Matches', '3.0 - Developing strokes', '3.5 - Has learned stroke form', '4.0 - Consistent with strokes', '4.5 - you know who you are...', '5', '5.5', '6.0+ watch me on TV']
      }

      interests.each do |name|
        interest = Interest.create(
            name: name
        )

        options = interests_options[name.downcase.to_sym]
        if options.present?
          option_name = options[0]
          options = options.delete_if { |x| x == option_name }
          options.each do |option|
            interest_option = InterestsOption.create(
                interest_id: interest.id,
                option_name: option_name,
                option_value: option
            )
          end
        end

      end
    end
  end

  def self.down

    drop_table :interests
    drop_table :interests_options
    drop_table :interests_users

  end
end
