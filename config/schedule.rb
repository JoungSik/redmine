# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# Learn more: http://github.com/javan/whenever

# Set environment
set :environment, ENV['RAILS_ENV'] || 'production'
set :output, '/data/logs/cron.log'

# Send reminders for issues due in the next 7 days
# Runs daily at 07:00 KST
every 1.day, at: '07:00' do
  rake "redmine:send_reminders days=7"
end

# You can add more cron jobs here as needed
# Examples:
#
# every 1.hour do
#   rake "redmine:some_task"
# end
#
# every :sunday, at: '03:00' do
#   rake "redmine:weekly_cleanup"
# end
