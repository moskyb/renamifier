require 'httparty'
require "shellwords"

EPISODE_REGEX = /S|s([0-9]{2,})E|e([0-9]{2,})/
TV_MAZE = "http://api.tvmaze.com/"
EXTS  = %w[avi flv mkv mov mp4]



def season_number(filename)
  filename.scan(EPISODE_REGEX).first[0]
end

def episode_number(filename)
  filename.scan(EPISODE_REGEX).first[1]
end

def hyphenize_name(name)
  name.downcase.gsub(" ", "-")
end

def get_epname(epfile, show_id)
  season = season_number(epfile).to_i
  episode = episode_number(epfile).to_i
                                                    # "episodebynumber?season=1&number=1"
  epname = HTTParty.get(TV_MAZE + "shows/#{show_id}/episodebynumber?season=#{season}&number=#{episode}")["name"]
end

puts "Please enter an ABSOLUTE filepath to look for TV episodes"
the_dir = Shellwords.escape(gets)
Dir.chdir(the_dir)
puts "Looking for video files with the pattern: #{the_dir}**/*.*"
puts "What's the name of the TV show?"
puts "This uses a fuzzy search, so you can look for things using natural language"
puts "For example, instead of searching for 'Battlestar Galactica', you could just search 'battlestar'"
name = gets.chomp

shows = HTTParty.get(TV_MAZE + "search/shows?q=" + hyphenize_name(name))
first_show_id = shows.dig(0,"show","id")
first_show_name = shows.dig(0,"show","name")

puts first_show_name
puts first_show_id

eps = EXTS.flat_map {|e| Dir.glob "#{the_dir}/**/*.#{e}"}
puts the_dir
eps.each do |e|
  print "#{e.gsub(the_dir, "")} => "
  epname = "#{first_show_name} - "
  epname << "S#{season_number(e)}"
  epname << "E#{episode_number(e)} - "
  epname << get_epname(e, first_show_id)
  puts epname
  File.rename(File.basename(e), epname)
end
