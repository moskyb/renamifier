require 'httparty'
require 'awesome_print'
require 'json'

TV_MAZE = "http://api.tvmaze.com/"

puts "What's the show you're looking for?"
show_name = gets
shows = HTTParty.get(TV_MAZE + "search/shows?q=" + show_name.gsub(" ", "-"))

shows.each do |show|
  puts show["show"]["name"] + " (" + show["show"]["premiered"].slice(0,4) + ")"
end
