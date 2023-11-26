require 'rubygems'
require 'telegram/bot'
require 'mechanize'
require_relative './services/scheduler'

API_TOKEN = ENV['API_TOKEN']
URL = 'https://makler.md'

@a = Mechanize.new do |agent|
  agent.user_agent_alias = ''
end

scheduler = Scheduler.create

bot = Telegram::Bot::Client.new(API_TOKEN)
@threads = []
@count = 0
Signal.trap('INT') { bot.stop }

kb_start = [[
  Telegram::Bot::Types::KeyboardButton.new(text: 'Start', callback_data: 'start')
]]

kb_stop = [[
  Telegram::Bot::Types::KeyboardButton.new(text: 'Stop', callback_data: 'stop')
]]

markup_start = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_start, resize_keyboard: true)
markup_stop = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_stop, resize_keyboard: true)

bot.listen do |message|
  case message.text
  when 'Start', '/start'
    @threads[@count] = Thread.new(message) do |msg|
      puts @threads.length
      Thread.current['thread_id'] = msg.chat.id
      scheduler.interval '6s' do |job|

      end
    end
    @threads.find_all(&:alive?).each(&:join) unless @threads.filter(&:alive?).empty?
  when 'Stop', '/stop'
    @threads.map! do |thr|
      Thread.kill(thr) if thr['thread_id'] == message.chat.id
    end
    bot.api.send_message(chat_id: message.chat.id, text: 'Bye', reply_markup: markup_start)
  end
end
