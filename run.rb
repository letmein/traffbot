# frozen_string_literal: true

require 'yaml'
require 'capybara'
require 'capybara/apparition'
require 'pry'

require_relative './lib/telegram/send_photo'

config = YAML.safe_load(IO.read('./secrets.yml'))
telegram_config = config['telegram']
bot_token = telegram_config['bot_token']
chat_id = telegram_config['chat_id']

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, window_size: [1400, 900])
end

# app = ->(_env) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
app = nil
session = Capybara::Session.new(:apparition, app)

url = config['sources'][0] || raise('No sources specified')

session.visit(url)

session.find('.sidebar-toggle-button__icon').click
session.assert_selector('.sidebar-view._collapsed')

sleep 5

file = Tempfile.new(['screenshot', '.png'])

begin
  session.save_screenshot(file.path)
  response = Telegram::SendPhoto.new(bot_token, chat_id).call(file)
  puts response.code.to_s
ensure
  file.close
  file.unlink
end
