# frozen_string_literal: true

require 'yaml'
require 'capybara'
require 'pry'
require 'webdrivers/chromedriver'

require_relative './lib/telegram/send_photo'

config = YAML.safe_load(IO.read('./secrets.yml'))
telegram_config = config['telegram']
bot_token = telegram_config['bot_token']
chat_id = telegram_config['chat_id']
url = config['sources'][0] || raise('No sources specified')

# app = ->(_env) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
app = nil
session = Capybara::Session.new(:selenium_chrome_headless, app)
session.driver.browser.manage.window.resize_to(1400, 900)

session.visit(url)

distance = session.first('.driving-route-form-view__route-title-secondary').text
estimate = session.first('.driving-route-form-view__route-subtitle').text
caption = "#{distance}, #{estimate}".downcase

session.find('.sidebar-toggle-button__icon').click
session.assert_selector('.sidebar-view._collapsed')

sleep 3

file = Tempfile.new(['screenshot', '.png'])

begin
  session.save_screenshot(file.path)
  response = Telegram::SendPhoto.new(bot_token, chat_id).call(file, caption)
  puts response.code.to_s
ensure
  file.close
  file.unlink
end
