# frozen_string_literal: true

# Modules
require_relative 'rubikey/terminal'
require_relative 'rubikey/vars'
require_relative 'rubikey/dialogue'
require_relative 'rubikey/cipher'
require_relative 'rubikey/password'
require_relative 'rubikey/masterpassword'
require_relative 'rubikey/passwordmanager'

# Acts as the main class.
# This class handles the main menu and calls upon the PasswordManager class for password-related work.
module Rubikey
  def self.run
    Terminal.clear
    Terminal.output(*Dialogue.welcome_message)

    # If this is the first time booting then prompt for new password
    @password_manager = MasterPassword.set? ? second_timer : first_timer

    main_menu
  end

  # Initial prompts to set the master password.
  def self.first_timer
    Terminal.output(*Dialogue.first_time_message)

    master_password = first_time_loop

    PasswordManager.new(master_password: master_password, new_password: true)
  end

  # Loop to keep prompting if passwords dont match.
  def self.first_time_loop
    loop do
      master_password = Terminal.password_prompt(*Dialogue.create_master_password_prompt)
      master_password_confirm = Terminal.password_prompt(*Dialogue.confirm_master_password_prompt)

      return master_password if master_password == master_password_confirm && !master_password.empty?
      master_password.empty? ? Terminal.output(*Dialogue.cant_be_empty) : Terminal.output(*Dialogue.passwords_do_not_match)
    end
  end

  # Prompts to input and check master password
  def self.second_timer
    master_password = Terminal.password_prompt(*Dialogue.enter_master_password_prompt)
    begin; PasswordManager.new(master_password: master_password)
    rescue StandardError
      master_password = Terminal.password_prompt(*Dialogue.incorrect_password_prompt)
      begin; PasswordManager.new(master_password: master_password)
      rescue StandardError
        Terminal.output(*Dialogue.too_many_failed_attempts)
        exit
      end
    end
  end

  # Display main menu and handle selection
  def self.main_menu
    menu_message = nil
    loop do
      Terminal.clear
      Terminal.output(*menu_message) if menu_message
      menu_message = nil
      selection = Terminal.prompt(*Dialogue.main_menu).downcase

      case selection
      when '1' # New password
        menu_message = new_password
      when '2' # Show Passwords
        menu_message = show_passwords(@password_manager.all_passwords)
      when '3' # Search Passwords
        menu_message = show_passwords(@password_manager.get_passwords_for(search_site))
      when '4' # Options
        menu_message = options
      when 'q' # Quit
        Terminal.clear
        @password_manager.close
        break
      else # Something else was input
        menu_message = Dialogue.invalid_option
      end
    end
  end

  # Prompts to save a new password
  def self.new_password
    website = Terminal.prompt(*Dialogue.new_password_website)
    username = Terminal.prompt(*Dialogue.ask_username)
    password_value = ['yes', 'y'].include?(Terminal.prompt(*Dialogue.ask_auto).downcase) ? Password.generate : Terminal.password_prompt(*Dialogue.ask_password)
    
    # Store password as a Password Class
    password = Password.new(website: website, username: username)
    password.update_password(password_value, @password_manager.master_password.password)
    
    # Save password in the password manager
    @password_manager.add_password(password)
    Dialogue.password_saved
  end

  # List the passwords provided
  def self.show_passwords(passwords)
    #passwords = @password_manager.all_passwords
    return Dialogue.no_passwords_saved if passwords.empty?

    Terminal.output(*Dialogue.password_list_header)
    passwords.each do |password|
      Terminal.output(*Dialogue.password_list_entry(
        id: password.id,
        website: password.website,
        username: password.username
      ))
    end

    loop do
      selection = Terminal.prompt(*Dialogue.password_selection_prompt).downcase
      return if selection == 'q'

      password = passwords.find { |entry| entry.id.to_s == selection }
      if password
        secret = password.get_password(@password_manager.master_password.password)
        #secret = @password_manager.master_password.decrypt(password.enc_password)
        Terminal.output(*Dialogue.revealed_password(secret))
      else
        Terminal.output(*Dialogue.password_id_not_found)
      end
    end
  end

  # Prompt for site to search for
  def self.search_site
    Terminal.prompt(*Dialogue.search_prompt)
  end

  # Display options menu and handle responce
  def self.options
    opt_message = nil
    loop do
      Terminal.clear
      Terminal.output(*opt_message) if opt_message
      opt_message = nil
      selection = Terminal.prompt(*Dialogue.opt_menu).downcase

      case selection
      when '1' # Change master password
        opt_message = change_master_password
      when 'q' # Return to menu
        Terminal.clear
        return
      else # somethine else was input
        opt_message = Dialogue.invalid_option
      end
    end
  end

  # Change master password prompts
  def self.change_master_password
    master = check_master_password_loop
    return if master.nil?
    password = new_password_loop
    @password_manager.change_master_password(master, password)
    return
  end

  # Pompt for master password and loop if its incorect
  def self.check_master_password_loop
    loop do
      master_password = Terminal.password_prompt(*Dialogue.enter_master_password_prompt)
      break if master_password == 'q'
      return master_password if @password_manager.master_password.auth(master_password)
      Terminal.output(*Dialogue.passwords_do_not_match)
    end
  end

  # Prompt for new passwords and loop if they dont match
  def self.new_password_loop
    loop do
      p_1 = Terminal.password_prompt(*Dialogue.create_master_password_prompt)
      p_2 = Terminal.password_prompt(*Dialogue.confirm_master_password_prompt)
      return p_1 if p_1 == p_2
      Terminal.output(*Dialogue.passwords_do_not_match)
    end
  end
end
