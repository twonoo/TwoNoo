namespace :followers do

  task :find_recommended => :environment do

    ActiveRecord::Base.connection.execute('TRUNCATE recommended_followers')
    User.find_in_batches(batch_size: 500) do |batch|
      batch.each do |user|
        user.find_people
      end
    end

  end

end
