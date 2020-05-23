require "tty-prompt"
require 'tty-box'
require 'tty-spinner'
class CommandLineInterface
    def welcome 
        prompt = TTY::Prompt.new
        prompt.select("welcome do you have an account with us if you do please sign in if not we can help you make an account today!") do |menu|
            menu.enum '.'
          
            menu.choice 'Sign In' do sign_in_menu end
            menu.choice 'No. I dont have an account' do create_profile end
            menu.choice 'exit' do end
            end
    end
    def sign_in_menu
        prompt = TTY::Prompt.new
       @username = prompt.ask('What is your Username? **keep in mind its case sensitive**', default: ENV['USER'])
       password = prompt.mask("Please enter your password")
       search = User.find_by(username: @username, password: password)
       findauser = User.where(id: search).first
       if findauser
        puts "Welcome back, #{@username}."
        menu
       else 
        prompt.select("Our record indicate that either your password or username is wrong. You can try again or if you dont have an account we can make you one.") do |menu|
            menu.enum '.'
          
            menu.choice 'Try Again' do sign_in_menu end
            menu.choice 'Ok, lets open an account' do create_profile end
            menu.choice 'Go Back'do welcome end
            end
        end
    end

    def create_profile
        puts "Thank you for choosing Bank of NYC"
        puts 
        puts "First let's start by setting up your profile"
        puts
        prompt = TTY::Prompt.new
       name = prompt.ask('To start im going to need your name? =>')
       age = prompt.ask('Next, enter your age =>')
       id_num = prompt.ask('Enter your ID number as it appears on your ID card =>')
       @username1 = prompt.ask('To have access to your accounts you need to create a username =>')
       passkey = prompt.mask('We also need a password. =>')
       occupation = prompt.ask('Also what do you do for a living? =>')
       salary = prompt.ask('What is your total yearly income?(no need to write $ we will convert it.) =>')
       phone_num = prompt.ask('Please enter your phone number with no - just straight numbers we can you use this to retrive your password if you ever forget it. =>')
       User.create(name: name, age:age, id_number: id_num, username:@username1, password:passkey, occupation:occupation, salary:salary, phone_number:phone_num)
       box = TTY::Box.success("You Have successfully created your profile")
       print box
       #bank account name , monthly fee, rewards
       bank_account_first_step
    end

    def bank_account_first_step
        prompt = TTY::Prompt.new
        prompt.select("What type of accounts are you interested in opening today? ") do |menu|
         menu.enum ')'
         menu.choice 'Premier Checking Account' do  @acc = "Premier Checking Account"  end
         menu.choice 'Premier Savings Account' do @acc = "Premier Savings Account" end
         menu.choice 'Premier Credit Card' do @acc = "Premier Credit Card"  end
         menu.choice 'Premier Certifacte of Deposit' do @acc = "Premier Certificate of Deposit" end
         end 
         premier_acc  
    end

    def premier_acc
        prompt = TTY::Prompt.new
       qforaccount= prompt.yes?("You are opening our #{@acc} Do you want to continue?")
          if qforaccount
            search_for_account = Bank.find_by(accounts:@acc)
            foundaccount = Bank.where(id:search_for_account).first
            search  = User.find_by(username: @username1)
            findauser = User.where(id: search).first
            u_id = findauser.id
            c_id = foundaccount.id
            Useraccount.create(user_id:u_id, bank_id:c_id, funds:0)
            spinner = TTY::Spinner.new("[:spinner] Verifying Account")
            spinner.success('(successful)')
            puts "You can now make deposits, withdrawals and open new accounts :)"
            menu
          else 
            bank_account_first_step
          end
    end

    def menu
        prompt = TTY::Prompt.new
        prompt.select("How can we Help you today.") do |prompt|
        prompt.enum '.'
        prompt.choice 'Make a deposit/payment' do  deposit end
        prompt.choice 'Make a withdrawal' do withdrawal end
        prompt.choice 'View Your balances' do balances end
        prompt.choice 'Open an Account' do bank_account_first_step end
        prompt.choice 'Make a transfer' do transfer end
        prompt.choice 'More options' do moreoptions end
        prompt.choice 'Exit' do puts "Have a great day"end
    end       
    end

    def deposit
        prompt = TTY::Prompt.new
        puts "Which account do you want to deposit in"
        search  = User.find_by(username: @username)
        findauser = User.where(id: search).first
        deposit1 = findauser.useraccounts.first
        findTheAccount = deposit1.bank_id
        nameTheAcccount = Bank.where(id:findTheAccount).uniq
        accounts = nameTheAcccount.pluck(:accounts)
        u_id = findauser.id 
        puts accounts
        paste = prompt.ask ('Please paste the account you want to deposit in =>')
        search_for_bank = Bank.find_by(accounts:paste)
        get_id = Bank.where(id:search_for_bank).first
        b_id = get_id.id 
        #im at the point where it lists the accounts but i want to find a way for a user to select 
        #the account using tty prompt
        puts "How much do you want to deposit/pay today?"
        money = prompt.ask('type the amount here => $')
        find_account = Useraccount.all.find_by(user_id:u_id,bank_id:b_id)
        find_account.increment!(:funds,money.to_i)
        puts "Youre all done you can view your balance in the menu section"
    end


end