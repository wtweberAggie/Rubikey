# frozen_string_literal: true

# Modules
require_relative 'vars'

module Rubikey
  # Container for blocks of text. These get used by the Terminal class.
  # By placing them here, it is much easier to change the display without searching the other classes.
  module Dialogue
    def self.welcome_message
      [
        TextColor::BOLD + "//////////////////////////////////////////////////////////\n",
        TextColor::GREEN + '                   Welcome to ',
        TextColor::RED + TextColor::BOLD + "Rubikey.\n",
        TextColor::BOLD + "//////////////////////////////////////////////////////////\n"
      ]
    end

    def self.first_time_message
      [
        TextColor::GREEN + "This is the first time you have used this application.\n",
        TextColor::GREEN + 'In order to secure your passwords, we require that you create a ',
        TextColor::YELLOW + TextColor::BOLD + 'master password.',
        "\n"
      ]
    end

    def self.create_master_password_prompt
      [
        TextColor::GREEN + 'Create a new ',
        TextColor::YELLOW + TextColor::BOLD + 'password:'
      ]
    end

    def self.confirm_master_password_prompt
      [
        TextColor::GREEN + 'Confirm the new ',
        TextColor::YELLOW + TextColor::BOLD + 'password:'
      ]
    end

    def self.passwords_do_not_match
      [
        TextColor::RED + "\nPassword does not match. Please try again.\n"
      ]
    end

    def self.enter_master_password_prompt
      [
        TextColor::GREEN + 'Enter your ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.incorrect_password_prompt
      [
        TextColor::RED + "Incorrect Password. Please try again...\n\n",
        TextColor::GREEN + 'Enter your ',
        TextColor::YELLOW + TextColor::BOLD + 'master password:'
      ]
    end

    def self.too_many_failed_attempts
      [
        TextColor::RED + 'Too many failed attempts, exiting Rubikey.'
      ]
    end

    def self.main_menu
      [
        TextColor::YELLOW + "\nMain menu\n",
        TextColor::GREEN + "1. New password\n",
        TextColor::GREEN + "2. Show passwords\n",
        TextColor::GREEN + "3. Search\n",
        TextColor::GREEN + "4. Options\n",
        TextColor::RED + "q. Quit\n\n",
        TextColor::YELLOW + TextColor::BOLD + 'Select an option:'
      ]
    end

    def self.new_password_website
      [
        TextColor::GREEN + "\n<<New password>>\n",
        TextColor::YELLOW + TextColor::BOLD + 'Enter the website:'
      ]
    end

    def self.ask_username
      [
        TextColor::YELLOW + TextColor::BOLD + 'Enter the username:'
      ]
    end

    def self.ask_auto
      [
        TextColor::YELLOW + TextColor::BOLD + 'Use strong password?(Y/N)'
      ]
    end

    def self.ask_password
      [
        TextColor::YELLOW + TextColor::BOLD + 'Enter the password:'
      ]
    end

    def self.password_list_header
      [
        TextColor::GREEN + "\nSaved passwords\n"
      ]
    end

    def self.password_selection_prompt
      [
        TextColor::BOLD + TextColor::RED + "\nEnter q to return to the main menu.\n",
        TextColor::YELLOW + TextColor::BOLD + 'Enter an ID to reveal its password:'
      ]
    end

    def self.option_not_available
      [TextColor::RED + 'That option is not available yet.']
    end

    def self.invalid_option
      [TextColor::RED + 'Invalid option.']
    end

    def self.password_saved
      [TextColor::GREEN + 'Password saved.']
    end

    def self.no_passwords_saved
      [TextColor::YELLOW + 'No passwords saved.']
    end

    def self.password_list_entry(id:, website:, username:)
      [TextColor::GREEN + "#{id}. #{website} | usr: <#{username}>"]
    end

    def self.revealed_password(password)
      [TextColor::WHITE + 'Password: ', TextColor::BLUE + password]
    end

    def self.password_id_not_found
      [TextColor::RED + 'No saved password has that ID.']
    end
    def self.search_prompt
      [
        TextColor::YELLOW + TextColor::BOLD + 'Search for site:'
      ]
    end
    def self.opt_menu
      [
        TextColor::YELLOW + "\nOptions menu\n",
        TextColor::GREEN + "1. Change master password\n",
        TextColor::RED + "q. Return to main menu\n\n",
        TextColor::YELLOW + TextColor::BOLD + 'Select an option:'
      ]
    end
  end
end
