# frozen_string_literal: true

env :PATH, ENV['PATH']

set :output, '/tmp/cron_log.log'

every :friday, at: '11:30 am' do
  rake 'run'
end
