require "tty-prompt"
require 'tty-box'
class CommandLineInterface
    def welcome 
        prompt = TTY::Prompt.new
        prompt.select("welcome do you have an account with us if you do please sign in if not we can help you make an account today!") do |menu|
            menu.enum '.'
          
            menu.choice 'Sign In' do sign_in_menu end
            menu.choice 'No. I dont have an account' do create_account1 end
            menu.choice 'exit' do end
            end
    end
    def sign_in_menu
        prompt = TTY::Prompt.new
       username = prompt.ask('What is your Username? **keep in mind its case sensitive**', default: ENV['USER'])
       password = prompt.mask("Please enter your password")
       name = username
       pass = password
       search = User.find_by(name: name, password: pass)
       findauser = User.where(id: search).first
       if findauser
        puts "Welcome back, #{name}."
        menu
       else 
        prompt.select("Our record indicate that either your password or username is wrong. You can try again or if you dont have an account we can make you one.") do |menu|
            menu.enum '.'
          
            menu.choice 'Try Again' do sign_in_menu end
            menu.choice 'Ok, lets open an account' do create_account end
            menu.choice 'Go Back'do welcome end
            end
        end
    end

    def create_account1
        puts "Thank you for choosing Bank of NYC"
        puts 
        puts "First let's start by setting up your profile"
        puts
        prompt = TTY::Prompt.new
       name = prompt.ask('To start im going to need your name? =>')
       age = prompt.ask('Next, enter your age =>')
       id_num = prompt.ask('Enter your ID number as it appears on your ID card =>')
       username1 = prompt.ask('To have access to your accounts you need to create a username =>')
       passkey = prompt.mask('We also need a password. =>')
       occupation = prompt.ask('Also what do you do for a living? =>')
       salary = prompt.ask('What is your total yearly income?(no need to write $ we will convert it.) =>')
       phone_num = prompt.ask('Please enter your phone number with no - just straight numbers we can you use this to retrive your password if you ever forget it. =>')
       User.create(name: name, age:age, id_number: id_num, username:username1, password:passkey, occupation:occupation, salary:salary, phone_number:phone_num)
       box = TTY::Box.success("You Have successfully created your profile")
       print box
    end


end