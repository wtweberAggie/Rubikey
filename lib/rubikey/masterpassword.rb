# frozen_string_literal: true

require 'bcrypt'
require_relative 'cipher'

# Master password to store and retrieve the master password, as well as check input passwords against the stored hash
class MasterPassword
  attr_reader :password

  def initialize(password)
    begin
      stored_hash = File.read('mp.hash')
    rescue StandardError
      raise ArgumentError, 'Master Password has not been set.'
    end
    raise ArgumentError, 'Master Password does not match.' unless BCrypt::Password.new(stored_hash) == password

    @password = password
    @hash = stored_hash
  end

  # Check method to verify a correct password
  def auth(password)
    BCrypt::Password.new(@hash) == password
  end

  # Function to hash and store a new password
  def update(current_password, new_password)
    raise ArgumentError, 'New password can not be empty' if new_password.empty?
    raise ArgumentError, 'Master Password is incorrect.' unless auth(current_password)

    @password = new_password
    @hash = BCrypt::Password.create(new_password)
    MasterPassword.store(new_password)
  end

  def decrypt(enc_password)
    PasswordCipher.decrypt(enc_password, @password)
  end

  # Store hash in mp.hash file
  def self.store(password)
    File.write('mp.hash', BCrypt::Password.create(password))
  end

  # Check if the mp.hash file exists to see if its been set.
  def self.set?
    File.exist?('mp.hash')
  end
end
