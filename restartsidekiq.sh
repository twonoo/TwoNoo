sidekiqctl stop sidekiq.pid
bundle exec sidekiq -d -L log/sidekiq.log -P sidekiq.pid
