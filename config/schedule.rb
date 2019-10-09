# frozen_string_literal: true

set :output, '/tmp/cron_log.log'

every :thursday, at: '9am' do
  rake 'run'
end
