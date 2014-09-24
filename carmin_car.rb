require 'rubygems' 
require 'bundler/setup' 

require 'json'

Dir["./lib/*.rb"].each {|file| require_relative file.gsub('.rb','') }
require_relative './feed/feed'
#require_relative './where/where'
require_relative './gauges/gauges'

APP_CONFIG = JSON.parse(File.read('./config.json'), symbolize_names: true)

feed = Carmin::Feed.new(APP_CONFIG[:feed])

#Carmin::Store.init

display = Carmin::Display.new

curr_data = feed.read
display.update(curr_data)


Thread.new do
  Looper.hz(2, debug: true) do
    #puts 'dis'
    display.update(curr_data.dup)
    #puts 'play'
  end
end

Looper.ms(100) do
  curr_data = feed.read
  #puts 'data'
end