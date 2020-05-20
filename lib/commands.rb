require "tty-prompt"
class CommandLineInterface
    def welcome 
        prompt = TTY::Prompt.new
        prompt.select("welcome do you have an account with us if you do please sign in if not we can help you make an account today!") do |menu|
            menu.enum '.'
          
            menu.choice 'Sign In' do sign_in_menu end
            menu.choice 'No. I dont have an account' do create_account end
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


end