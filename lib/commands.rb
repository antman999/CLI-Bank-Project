require "tty-prompt"
require 'tty-box'
require 'tty-spinner'
require 'tty-table'
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
    @username = prompt.ask('To have access to your accounts you need to create a username =>')
    passkey = prompt.mask('We also need a password. =>')
    occupation = prompt.ask('Also what do you do for a living? =>')
    salary = prompt.ask('What is your total yearly income?(no need to write $ we will convert it.) =>')
    phone_num = prompt.ask('Please enter your phone number with no - just straight numbers we can you use this to retrive your password if you ever forget it. =>')
       
    User.create(name: name, age:age, id_number: id_num, username:@username, password:passkey, occupation:occupation, salary:salary, phone_number:phone_num)
    box = TTY::Box.success("You Have successfully created your profile")     
       print box
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
      search = User.find_by(username: @username)
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
   prompt.choice 'Make a deposit/payment' do  deposit end #done
   prompt.choice 'Make a withdrawal' do withdrawal end #done
   prompt.choice 'View Your balances' do balances end #kinda done
   prompt.choice 'Open an Account' do bank_account_first_step end #done
   prompt.choice 'Make a transfer' do transfer end #done
   prompt.choice 'More options' do moreoptions end
   prompt.choice 'Exit' do puts "Have a great day"end #done
    end       
 end

 def deposit
   prompt = TTY::Prompt.new
   puts "Which account do you want to deposit in"
   search  = User.find_by(username: @username)
   findauser = User.where(id: search).first
   deposit1 = findauser.useraccounts
   findTheAccount = deposit1.map do |v|
    v.bank_id
   end
   nameTheAcccount = Bank.where(id:findTheAccount).uniq
   accounts = nameTheAcccount.pluck(:accounts)
   u_id = findauser.id 
   puts accounts
   paste = prompt.ask ('Please paste the account you want to deposit in =>')
   search_for_bank = Bank.find_by(accounts:paste)
   get_id = Bank.where(id:search_for_bank).first
   b_id = get_id.id 
   puts "How much do you want to deposit/pay today?"
   money = prompt.ask('type the amount here => $')
   find_account = Useraccount.all.find_by(user_id:u_id,bank_id:b_id)
   find_account.increment!(:funds,money.to_i)
   puts "Youre all done you can view your balance in the View my balances section"
   menu
 end

 def withdrawal
   prompt = TTY::Prompt.new
   puts "Which account do you want to withdraw from "
   search  = User.find_by(username: @username)
   findauser = User.where(id: search).first
   deposit1 = findauser.useraccounts
   findTheAccount = deposit1.map do |v|
    v.bank_id
   end
   nameTheAcccount = Bank.where(id:findTheAccount).uniq
   accounts = nameTheAcccount.pluck(:accounts)
   u_id = findauser.id 
   puts accounts
   paste = prompt.ask ('Please paste the account you want to Withdraw from =>')
   search_for_bank = Bank.find_by(accounts:paste)
   get_id = Bank.where(id:search_for_bank).first
   b_id = get_id.id 
   #im at the point where it lists the accounts but i want to find a way for a user to select 
   #the account using tty prompt
   puts "How much do you want to withdraw today?"
   money = prompt.ask('type the amount here => $')
   find_account = Useraccount.all.find_by(user_id:u_id,bank_id:b_id)
   find_account.decrement!(:funds,money.to_i)
   puts "Youre all done you can view your balance in the View my balances section"
   menu
 end
   
 def balances
  puts "Welcome back #{@username} these are you balances,"
  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  deposit1 = findauser.useraccounts
  deposit_id = deposit1.pluck(:bank_id).uniq
  bank = Bank.where(id:deposit_id)
  a1 = bank.pluck(:accounts)
  a2 = deposit1.pluck(:funds)
   table = TTY::Table.new ['Account','Balances'], [[a1, a2]]
   puts table.render :ascii, multiline: true
    prompt = TTY::Prompt.new
    prompt.select("What would you like to do next?") do |prompt|
    prompt.enum '.'
    prompt.choice 'Make a deposit/payment' do  deposit end
    prompt.choice 'Make a withdrawal' do withdrawal end
    prompt.choice 'Go back to the main menu' do menu end
    end
 end

 def transfer
 prompt = TTY::Prompt.new
 zelle = prompt.yes?("Welcome to our totally not zelle app do you want to make a transfer today?")
    if zelle
    ####recipient###
    ask_for_username_for_friend = prompt.ask("Please enter the username of the person you want to transfer to.")
    search_for_friend = User.find_by(username:ask_for_username_for_friend)
    found_friend = User.where(id: search_for_friend).first
    account_for_that_friend = found_friend.useraccounts.first
    bank_id_for_friend = account_for_that_friend.bank_id
    friends_id = found_friend.id 
    ###sender####
    amount_for_friend = prompt.ask("Please enter the amount you would like to send => $")
    search_for_sender = User.find_by(username: @username)
    find_the_sender = User.where(id: search_for_sender).first       
    accounts_for_sender = find_the_sender.useraccounts.first         
    found_account_for_sender= accounts_for_sender.bank_id
    name_of_accounts_sender_has = Bank.where(id:found_account_for_sender).uniq
    accounts_array = name_of_accounts_sender_has.pluck(:accounts)
    sender_id = find_the_sender.id 
    ###### method starts ####
    puts accounts_array      
    paste_account = prompt.ask ('Please copy/paste the account you want to transfer from =>')
    search_for_the_exact_account = Bank.find_by(accounts:paste_account)
    get_bank_id_sender = Bank.where(id:search_for_the_exact_account).first
    bank_id_for_sender= get_bank_id_sender.id 
    last_chance_before_transfer = prompt.yes?("Are you sure you want to trasnfer $#{amount_for_friend} to #{ask_for_username_for_friend} ")
        if last_chance_before_transfer
        find_account_user = Useraccount.all.find_by(user_id:sender_id,bank_id:bank_id_for_sender)
        find_account_user.decrement!(:funds,amount_for_friend.to_i)
        find_account_friend = Useraccount.all.find_by(user_id:friends_id,bank_id:bank_id_for_friend)
        find_account_friend.increment!(:funds,amount_for_friend.to_i)
        puts "Thank you for chosing us your transfer to #{ask_for_username_for_friend} is complete"
        prompt.select("What would you like to do next?") do |prompt|
        prompt.enum '.'
        prompt.choice 'Make a deposit/payment' do  deposit end
        prompt.choice 'Go back to the main menu' do menu end
            end
        else
        menu
        end
    else
    menu
    end
 end

 def moreoptions
  prompt = TTY::Prompt.new
   prompt.select("How can we Help you today?") do |prompt|
   prompt.enum '.'
   prompt.choice 'Check if youre qualified for our Elite Accounts' do eliteaccount end 
   prompt.choice 'Close my Account' do closeaccount end #done
   prompt.choice 'update my phone number' do updatephone end 
   prompt.choice 'update my password' do updatepassword end
   prompt.choice 'Go back to Main Menu' do menu end 
   prompt.choice 'Exit' do puts "Have a great day"end
    end       
 end

 def closeaccount
  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  prompt = TTY::Prompt.new
  ask_to_close= prompt.yes?("We are really sad to see you go, ARE you 100% sure you want to delete your account. There's no going back, we will mail you a check within 7-10 business days.")
  if ask_to_close
    puts "You're all set your accounts have been closed. Have a great day!"
    User.delete(findauser)
  else
    menu
  end
 end

 #allowed to withdraw?

#ascii text 

#big lettering on beggining if youre a premium member

#forgot my password

#fix some typos

#try to make font bigger somehow

#I need to add if account is currently open or in closed status

# fix balances

#not allowed to withdraw/transfer if you have no money 
end