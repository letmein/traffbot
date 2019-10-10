# frozen_string_literal: true

env :PATH, ENV['PATH']

set :output, '/tmp/cron_log.log'

every :thursday, at: '9am' do
  rake 'run'
end
