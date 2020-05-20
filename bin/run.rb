require_relative '../config/environment'
ActiveRecord::Base.logger = nil

cli = CommandLineInterface.new  

puts "Welcome to Bank Of NYC"

puts 
puts

cli.welcome
