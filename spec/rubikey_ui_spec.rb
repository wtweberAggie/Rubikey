# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rubikey do
  # Clean files to allow for tests from initial state
  before do
    File.delete('pw.db') if File.exist?('pw.db')
    File.delete('mp.hash') if File.exist?('mp.hash')
  end
  after do
    File.delete('pw.db') if File.exist?('pw.db')
    File.delete('mp.hash') if File.exist?('mp.hash')
  end

  describe '.run' do
    it 'displays the welcome message' do
      allow(MasterPassword).to receive(:set?).and_return(false)
      allow(Rubikey).to receive(:first_timer)
      allow(Rubikey).to receive(:main_menu)

      expect { Rubikey.run }.to output(
        a_string_including('Welcome to ', 'Rubikey.')
      ).to_stdout
    end
  end

  describe '.main_menu' do
    it 'closes the password manager when q is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('q')

      Rubikey.main_menu

      expect(password_manager).to have_received(:close)
    end

    it 'opens the password list when option 2 is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('2', 'q')
      expect(Rubikey).to receive(:show_passwords).with(any_args)

      Rubikey.main_menu
    end

    it 'opens the search list when option 3 is selected and a search input is given' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('2', 'google', 'q')
      expect(Rubikey).to receive(:show_passwords).with(any_args)

      Rubikey.main_menu
    end

    it 'opens the options when option 4 is selected' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('4', 'q')
      expect(Rubikey).to receive(:options)#.with(anything)

      Rubikey.main_menu
    end

    it 'keeps an invalid-option message above the next menu' do
      password_manager = instance_double(PasswordManager, close: nil)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      selections = %w[invalid q]
      allow(Rubikey::Terminal).to receive(:prompt) do |*messages|
        puts messages.join
        selections.shift
      end

      expect { Rubikey.main_menu }.to output(/Invalid option\..*Main menu/m).to_stdout
    end

    it 'keeps the empty-password message above the next menu' do
      password_manager = instance_double(PasswordManager, close: nil, all_passwords: [])
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      selections = %w[2 q]
      allow(Rubikey::Terminal).to receive(:prompt) do |*messages|
        puts messages.join
        selections.shift
      end

      expect { Rubikey.main_menu }.to output(/No passwords saved\..*Main menu/m).to_stdout
    end
  end

  describe '.new_password' do
    it 'encrypts and saves the prompted password' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      allow(Rubikey::Terminal).to receive(:prompt).and_return('example.com', 'alice')
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('secret')

      Rubikey.new_password

      saved_password = password_manager.get_passwords_for('example.com').first
      expect(saved_password.username).to eq('alice')
      expect(saved_password.get_password('masterPassword')).to eq('secret')
    ensure
      password_manager&.close
    end
  end

  describe '.show_passwords' do
    it 'lists account details and reveals the password after its ID is selected' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
      allow(Rubikey::Terminal).to receive(:prompt).and_return(password.id.to_s, 'q')

      expect { Rubikey.show_passwords(password_manager.all_passwords) }.to output(
        a_string_including('example.com', 'alice', 'Password: ', 'secret')
      ).to_stdout
    ensure
      password_manager&.close
    end

    it 'reports when no passwords are saved' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)

      expect(Rubikey.show_passwords(password_manager.all_passwords)).to eq(Rubikey::Dialogue.no_passwords_saved)
    ensure
      password_manager&.close
    end

    it 'colors the password label white and the revealed value blue' do
      expect(Rubikey::Dialogue.revealed_password('secret')).to eq(
        [Rubikey::TextColor::WHITE + 'Password: ', Rubikey::TextColor::BLUE + 'secret']
      )
    end
  end

  describe '.change_master_password' do
    it '' do
      password_manager = PasswordManager.new(master_password: 'masterPassword', new_password: true)
      Rubikey.instance_variable_set(:@password_manager, password_manager)
      password = Password.new(website: 'example.com', username: 'alice')
      password.update_password('secret', 'masterPassword')
      password_manager.add_password(password)
    end

  end

  describe '.first_timer' do
    before do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    after do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    it 'creates a master password when one does not exist' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword', 'masterPassword')

      password_manager = Rubikey.first_timer
      password_manager.close

      expect(File).to exist('mp.hash')
      expect(MasterPassword.set?).to be true
    end

    it 'creates a master password that can be used to authenticate' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword', 'masterPassword')

      password_manager = Rubikey.first_timer
      password_manager.close
      expect { MasterPassword.new('masterPassword') }.not_to raise_error
    end

    it 'asks for the password again when the passwords do not match' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return(
        'masterPassword',
        'wrongPassword',
        'masterPassword',
        'masterPassword'
      )

      expect do
        password_manager = Rubikey.first_timer
        password_manager.close
      end.to output(
        a_string_including('Password does not match. Please try again.')
      ).to_stdout

      expect(MasterPassword.set?).to be true
    end
  end

  describe '.second_timer' do
    before do
      File.delete('mp.hash') if File.exist?('mp.hash')
      MasterPassword.store('masterPassword')
    end

    after do
      File.delete('mp.hash') if File.exist?('mp.hash')
    end

    it 'accepts the correct master password' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('masterPassword')

      password_manager = Rubikey.second_timer
      password_manager.close
    end

    it 'asks for the password again after an incorrect password' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return('wrongPassword', 'masterPassword')

      expect(Rubikey::Terminal).to receive(:password_prompt).twice

      password_manager = Rubikey.second_timer
      password_manager.close
    end

    it 'exits after two incorrect passwords' do
      allow(Rubikey::Terminal).to receive(:password_prompt).and_return(
        'wrongPassword',
        'wrongPassword'
      )
      allow(Rubikey).to receive(:exit)

      expect { Rubikey.second_timer }.to output(
        a_string_including('Too many failed attempts')
      ).to_stdout
    end
  end
end
