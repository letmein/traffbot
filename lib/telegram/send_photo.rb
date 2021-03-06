# frozen_string_literal: true

module Telegram
  class SendPhoto
    def initialize(bot_token, chat_id)
      @bot_token = bot_token.to_s
      @chat_id = chat_id.to_s
    end

    def call(file, caption = nil)
      request = Net::HTTP::Post.new(uri)
      request.set_form(form_data(file, caption), 'multipart/form-data')

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: ssl?) do |http|
        http.request(request)
      end
    end

    private

    attr_reader :bot_token, :chat_id

    def form_data(file, caption)
      params = [
        ['photo', file],
        ['chat_id', chat_id],
        ['disable_notification', 'true']
      ]
      params << ['caption', caption] if caption
      params
    end

    def uri
      @uri ||= URI("https://api.telegram.org/bot#{bot_token}/sendPhoto")
    end

    def ssl?
      uri.scheme == 'https'
    end
  end
end
