require_relative '../config/environment'
ActiveRecord::Base.logger = nil

cli = CommandLineInterface.new  
require 'tty-color'
require 'pastel'
require 'tty-font'
pastel = Pastel.new
font = TTY::Font.new(:doom)
puts pastel.bright_red.on_black.bold(font.write("Welcome  To  Bank  Of  N.Y.C"))
puts 
puts

cli.welcome
