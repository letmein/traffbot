# frozen_string_literal: true

require 'yaml'
require 'capybara'
require 'capybara/apparition'
require 'pry'

config = YAML.safe_load(IO.read('./secrets.yml'))

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

  telegram_config = config['telegram']
  bot_token = telegram_config['bot_token']
  chat_id = telegram_config['chat_id']

  uri = URI("https://api.telegram.org/bot#{bot_token}/sendPhoto")
  request = Net::HTTP::Post.new(uri)
  form_data = [['photo', file], ['chat_id', chat_id.to_s]]

  request.set_form(form_data, 'multipart/form-data')

  use_ssl = uri.scheme == 'https'

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl) do |http|
    http.request(request)
  end

  puts response.code.to_s
ensure
  file.close
  file.unlink
end
