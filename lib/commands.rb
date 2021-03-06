require "tty-prompt"
require 'tty-box'
require 'tty-spinner'
require 'tty-table'
require 'tty-color'
require 'pastel'
require 'tty-font'
require 'tty-pie'
class CommandLineInterface
 def welcome
    pastel = Pastel.new 
    prompt = TTY::Prompt.new
    prompt.select("welcome to our online banking app. How can we help you today? ") do |menu|
     menu.enum '.'
     menu.choice 'Sign In' do sign_in_menu end
     menu.choice 'Create An Account' do create_profile end
     menu.choice 'Exit' do end
    end
 end

 def sign_in_menu
    prompt = TTY::Prompt.new
    @username = prompt.ask('Please Enter your Username? **keep in mind its case sensitive**', default: ENV['USER'])
    password = prompt.mask("Please Enter your Password")
    search = User.find_by(username: @username, password: password)
    findauser = User.where(id: search).first
      if findauser
       puts "Welcome back, #{findauser.name.capitalize}."
       spinner = TTY::Spinner.new("[:spinner]  Logging In...")
       spinner.auto_spin
       sleep(2)
       pastel = Pastel.new
       system 'clear'
       pastel.green.bold(spinner.success('( Verified ✅)'))
       menu
      else 
        spinner = TTY::Spinner.new("[:spinner]  Logging In...")
        spinner.auto_spin
        sleep(2)
        spinner.error('( Failed ❌)')
      prompt.select("Our records indicate that either your password or username is wrong. You can try again or if you dont have an account we can make you one.") do |menu|
       menu.enum '.'
       menu.choice 'Try Again' do sign_in_menu end
       menu.choice 'Forgot my password' do forgotpassword end
       menu.choice 'Ok, lets open an account' do create_profile end
       menu.choice 'Go Back'do welcome end
       system 'clear'
      end
    end
 end

 def forgotpassword
  prompt = TTY::Prompt.new
  @username = prompt.ask('What is your Username? **keep in mind its case sensitive**', default: ENV['USER'])
  phone = prompt.ask("To view your password please enter your phone number")
  search = User.find_by(username: @username, phone_number: phone)
  findauser = User.where(id: search).first
  if findauser 
    prompt.select("your password is #{search.password} you can go ahead and log in") do |menu|
      menu.enum '.'
      menu.choice 'Try Again' do sign_in_menu end
      menu.choice 'exit' do puts "Have a great day!" end
      end
    else 
      puts "either one of the 2 is wrong try again"
      system 'clear'
      sign_in_menu
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
    spinner = TTY::Spinner.new("[:spinner] Verifying Profile")
    spinner.auto_spin
    sleep(2)
    spinner.success('(✅✅ successful ✅✅)')
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
      spinner.auto_spin
      sleep(2)
      spinner.success('(✅✅ successful ✅✅)')
      puts "You can now make deposits, withdrawals and open new accounts :)"
      system 'clear'
      menu
      else 
      bank_account_first_step
    end
 end

 def check_for_status
  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  deposit1 = findauser.useraccounts
  g = deposit1.map do |v|
       v.gold_rewards
  end
  s = deposit1.map do |v|
    v.silver_rewards
  end
  d = deposit1.map do |v|
    v.diamond_rewards
  end

  if g[0] == true 
    font = TTY::Font.new(:straight)
    pastel = Pastel.new
    puts pastel.bright_yellow.on_black(font.write("GOLD MEMBER", letter_spacing: 2))
  end
  if s[0] == true
    font = TTY::Font.new(:standard)
    pastel = Pastel.new
    puts pastel.bright_white.on_black(font.write(" SILVER MEMBER ", letter_spacing: 2))
  end
  if d[0] == true
    font = TTY::Font.new(:doom)
    pastel = Pastel.new
    puts pastel.bright_cyan.on_black.bold(font.write(" DIAMOND MEMBER ", letter_spacing: 4))
  end
 end

 def menu
 check_for_status
   prompt = TTY::Prompt.new
   prompt.select("How can we Help you today?") do |prompt|
   prompt.enum '.'
   prompt.choice 'Make a deposit/payment  🏧' do  deposit end #done
   prompt.choice 'Make a withdrawal  💵' do withdrawal end #done
   prompt.choice 'View Your balances  💳' do balances end #kinda done
   prompt.choice 'Open an Account  📈' do bank_account_first_step end #done
   prompt.choice 'Make a transfer  🔁' do transfer end #done
   prompt.choice 'More options  ❗️' do moreoptions end
   prompt.choice 'Exit  👋🏻' do  spinner = TTY::Spinner.new("[:spinner]  Logging Out...")
    spinner.auto_spin
    sleep(2)
    spinner.success('( Logged out. have a great day!)')
    system 'clear' end #done
    end     
 end

 def deposit
   spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
   spinner.auto_spin
   sleep(1)
   spinner.stop('Connected!')
   prompt = TTY::Prompt.new
   puts "Which account do you want to deposit into"
   search  = User.find_by(username: @username)
   findauser = User.where(id: search).first
   deposit1 = findauser.useraccounts
   findTheAccount = deposit1.map do |v|
    v.bank_id
   end
   nameTheAcccount = Bank.where(id:findTheAccount).uniq
   accounts = nameTheAcccount.pluck(:accounts)
   u_id = findauser.id 
   paste = prompt.select("Select the account you want to deposit in 🤑", accounts)
   search_for_bank = Bank.find_by(accounts:paste)
   get_id = Bank.where(id:search_for_bank).first
   b_id = get_id.id 
   puts "How much do you want to deposit/pay today?💸"
   money = prompt.ask('type the amount here => $')
   find_account = Useraccount.all.find_by(user_id:u_id,bank_id:b_id)
   find_account.increment!(:funds,money.to_i)
   spinner = TTY::Spinner.new("[:spinner]  💵 Verifying deposit")
   spinner.auto_spin
   sleep(2)
   spinner.success('(✅✅ successful ✅✅)')
   puts "Youre all set here is your virtual receipt"
   table = TTY::Table.new ['Account','Balance'], [[paste,find_account.funds ]]
    puts table.render(:ascii)
    prompt.keypress("Press any key to continue to the menu, resumes automatically in :countdown ...", timeout: 15)
    system 'clear'
    menu
 end

 def withdrawal
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
   prompt = TTY::Prompt.new
   puts "Which account do you want to withdraw from "
   search  = User.find_by(username: @username)
   findauser = User.where(id: search).first
   deposit1 = findauser.useraccounts
   findTheAccount = deposit1.map do |v|
    v.bank_id
   end
   nameTheAcccount = Bank.where(id:findTheAccount,withdrawable:true).uniq
   accounts = nameTheAcccount.pluck(:accounts)
   u_id = findauser.id 
   paste = prompt.select("Select the account you want to withdraw from", accounts)
   search_for_bank = Bank.find_by(accounts:paste)
   get_id = Bank.where(id:search_for_bank).first
   b_id = get_id.id 
   #im at the point where it lists the accounts but i want to find a way for a user to select 
   #the account using tty prompt
   puts "How much do you want to withdraw today?"
   money = prompt.ask('type the amount here => $')
   find_account = Useraccount.all.find_by(user_id:u_id,bank_id:b_id)
   if find_account.funds > money.to_i
   find_account.decrement!(:funds,money.to_i)
   spinner = TTY::Spinner.new("[:spinner]  💵 Verifying withdraw")
   spinner.auto_spin
   sleep(2)
   spinner.success('(✅✅ successful ✅✅)')
   puts "✅✅✅Youre all set here is your virtual receipt✅✅✅"
   table = TTY::Table.new ['Account','Balance'], [[paste,find_account.funds ]]
    puts table.render(:ascii)
    prompt.keypress("Press any key to continue to the menu, resumes automatically in :countdown ...", timeout: 15)
    system 'clear'
    menu
   else
   spinner = TTY::Spinner.new("[:spinner]  💵 Verifying withdraw")
   spinner.auto_spin
   sleep(2)
   spinner.success('(❌❌ Error ❌❌)')
   prompt.select("❌❌❌Sorry you gotta get your money up to make that withdrawal please try a lower amount.❌❌❌") do |prompt|
   prompt.enum '.'
   prompt.choice 'Make a deposit/payment' do  deposit end
   prompt.choice 'Menu' do menu end 
   end
   end
 end
   
 def balances
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
  puts "Welcome back #{@username} these are you balances,"

  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  deposit1 = findauser.useraccounts
   findTheAccount = deposit1.map do |v|
    v.bank_id
   end
   nameTheAcccount = Bank.where(id:findTheAccount).uniq
   accounts = nameTheAcccount.pluck(:accounts)
    prompt = TTY::Prompt.new
    paste = prompt.select("Select the account you want to view the balances from", accounts)
    s = Bank.where(accounts:paste)
    d = s.map do |v|
      v.id
    end
     h = deposit1.where(bank_id:d)
     a2=h.pluck(:funds)
     a3=s.pluck(:interest_rate)
    puts
    pastel = Pastel.new
    puts pastel.red.bold("#{paste} = $#{a2} your current intrest rate is #{a3}.")
    puts
    prompt.select("What would you like to do next?") do |prompt|
    prompt.enum '.'
    prompt.choice 'Make a deposit/payment' do  deposit end
    prompt.choice 'Make a withdrawal' do withdrawal end
    prompt.choice 'Go back to the main menu' do menu end
    end
 end

 def transfer
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
 prompt = TTY::Prompt.new
 zelle = prompt.yes?("Welcome to our totally not zelle app do you want to make a transfer today?")
    if zelle
    ####recipient###
    ask_for_username_for_friend = prompt.ask("Please enter the username of the person you want to transfer to.")
    search_for_friend = User.find_by(username:ask_for_username_for_friend)
    if search_for_friend
      spinner = TTY::Spinner.new("[:spinner]  Verifying account")
      spinner.auto_spin
      sleep(1)
      spinner.success('✅✅(Success)✅✅')
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
    paste_account = prompt.select(" please select the account you want to transfer from", accounts_array)
    search_for_the_exact_account = Bank.find_by(accounts:paste_account)
    get_bank_id_sender = Bank.where(id:search_for_the_exact_account).first
    bank_id_for_sender= get_bank_id_sender.id 
    last_chance_before_transfer = prompt.yes?("Are you sure you want to transfer $#{amount_for_friend} to #{ask_for_username_for_friend} ")
        if last_chance_before_transfer
        find_account_user = Useraccount.all.find_by(user_id:sender_id,bank_id:bank_id_for_sender)
        find_account_user.decrement!(:funds,amount_for_friend.to_i)
        find_account_friend = Useraccount.all.find_by(user_id:friends_id,bank_id:bank_id_for_friend)
        find_account_friend.increment!(:funds,amount_for_friend.to_i)
        spinner = TTY::Spinner.new("[:spinner]   🔁 Verifying Transfer 🔁 ")
        spinner.auto_spin
        sleep(2)
        spinner.success('( 🔁 Success 🔁 )')
        puts "Thank you for chosing us your transfer to #{ask_for_username_for_friend} is complete"
        puts "✅✅✅Youre all set here is your virtual receipt✅✅✅"
        table = TTY::Table.new ['Account','Balance'], [[paste_account,find_account_user.funds ]]
        puts table.render(:ascii)
        prompt.keypress("Press any key to continue to the menu, resumes automatically in :countdown ...", timeout: 15)
        system 'clear'
        menu
        else
        menu
        end
      else
        spinner = TTY::Spinner.new("[:spinner]  Verifying account")
        spinner.auto_spin
        sleep(1)
        spinner.success('(❌❌ Error ❌❌)')
        puts "I cant find that account make sure you spelled it right."
        transfer
      end
    else
    menu
    end
 end

 def moreoptions
  prompt = TTY::Prompt.new
   prompt.select("How can we Help you today?") do |prompt|
   prompt.enum '.'
   prompt.choice 'Check if youre qualified for our Elite Accounts  👑' do eliteaccount end 
   prompt.choice 'Close my Account  🚶🏽‍♀️' do closeaccount end 
   prompt.choice 'update my phone number  ☎️' do updatephone end 
   prompt.choice 'update my password  ❌' do updatepassword end 
   prompt.choice 'Go back to Main Menu  ⏪' do menu end 
   prompt.choice 'Exit  👋🏻' do puts "Have a great day"end 
    end       
 end

 def closeaccount
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
  search  = User.find_by(username: @username)
  findauser =User.where(id: search).first
  prompt = TTY::Prompt.new
  ask_to_close= prompt.yes?("😞 We are really sad to see you go, ARE you 100% sure you want to delete your account. There's no going back, we will mail you a check within 7-10 business days.")
  if ask_to_close
    spinner = TTY::Spinner.new("[:spinner] Deleting Account...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(2)
  spinner.stop('Deleted!')
    puts "You're all set your accounts have been closed. Have a great day!"
    User.delete(findauser)
  else
    menu
  end
 end

 def updatephone
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  prompt = TTY::Prompt.new
  number = prompt.yes?("Welcome back. Do you want to update your phone number?")
   if number
    updatenumber = prompt.ask("this is you current phone number #{findauser.phone_number}. Please enter a new one!")
    findauser.update(phone_number:updatenumber)
    puts "You're all set, your new number on file is #{findauser.phone_number}."
    puts "Have a great day"
    menu
   else 
    menu
   end
 end

  def updatepassword
    spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
    spinner.auto_spin
    sleep(1)
    spinner.stop('Connected!')
    search  = User.find_by(username: @username)
    findauser = User.where(id: search).first
    prompt = TTY::Prompt.new
    number = prompt.yes?("Welcome back. Do you want to update your password?")
    if number
      updatepass = prompt.ask("this is you current password #{findauser.password}. Please enter a new one!")
      findauser.update(password:updatepass)
      puts "You're all set, your new password on file is #{findauser.password}."
      puts "Have a great day"
      menu
    else 
      menu
    end

 end

 def eliteaccount
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  sleep(1)
  spinner.stop('Connected!')
  spinner = TTY::Spinner.new
  prompt = TTY::Prompt.new
  search  = User.find_by(username: @username)
  findauser = User.where(id: search).first
  deposit1 = findauser.useraccounts
  findTheAccount = deposit1.map do |v|
   v.funds
  end
  firstprompt = prompt.yes?("Welcome back do you want to apply to our elite accounts")
  puts "there are 3 tiers of elite accounts the first one is gold rewards in order to qualify for this acccount you need atleast $20,000 in your checking account."
  puts
  puts "The second tier is silver with this tier you need to have atleast $50,000 in your account you will get a 10% interest boost on your accounts."
  puts
  puts "Our most premium tier is the absolute best we have. You have to maintain atleast $100,000 with this is tier you will get a 20% boost on all your acccounts!"
  confirm = prompt.yes?("Please confirm you want use to check if you qualify for one of our accounts :)")
  spinner = TTY::Spinner.new("[:spinner] Loading ...", format: :pulse_2, interval: 20)
  spinner.auto_spin
  if confirm
    if findTheAccount.sum > 100000
      deposit1.update(diamond_rewards:true)
      deposit1.update(silver_rewards:false)
      deposit1.update(gold_rewards:false)
      spinner.auto_spin
      sleep(2)
      puts "CONGRATS!! you have just enrolled in our DIAMOND tier account enjoy all the extra benefits"
      spinner.stop('Done!')
      menu
    elsif findTheAccount.sum > 50000
      deposit1.update(silver_rewards:true)
      deposit1.update(diamond_rewards:false)
      deposit1.update(gold_rewards:false)
      spinner.auto_spin
      sleep(2)
      puts "CONGRATS!! you have just enrolled in our SILVER tier account enjoy all the extra benefits"
      spinner.stop('Done!')
      menu
    elsif findTheAccount.sum > 20000
      spinner.auto_spin
      sleep(2)
      deposit1.update(gold_rewards:true)
      deposit1.update(silver_rewards:false)
      deposit1.update(diamond_rewards:false)
      puts "CONGRATS!! you have just enrolled in our GOLD tier account enjoy all the extra benefits"
      spinner.stop('Done!')
      menu
    elsif findTheAccount.sum < 20000
      deposit1.update(gold_rewards:false)
      deposit1.update(silver_rewards:false)
      deposit1.update(diamond_rewards:false)
      spinner.auto_spin
      sleep(2)
      puts "You dont currently qualify for one of our elite tiers please try again when you meet the balance requirement!"
      spinner.stop('Done!')
      menu
    end
   else
    menu
  end
 end
end