# frozen_string_literal: true

require_relative 'cipher'

# Stores website info and encrypts passwords using a master master password for later decryption.
class Password
  attr_accessor :id
  attr_reader :website, :username, :enc_password

  # Initialization of a password object without the encrypted data
  def initialize(website:, username:, enc_password: nil, id: nil)
    raise ArgumentError, 'Website can not be empty' if website.empty?
    raise ArgumentError, 'Username can not be empty' if username.empty?

    @website = website
    @username = username
    @enc_password = enc_password
    @id = id
  end

  def ==(other)
    return false unless other.is_a?(Password)

    conditions = [
      website == other.website,
      username == other.username,
      enc_password == other.enc_password
    ]
    conditions.all?
  end

  # Initilization of a password from the sql row returned from the stored db
  def self.new_from_db(row)
    raise ArgumentError, 'Nothing found in database' if row.nil?

    new(website: row[1], username: row[2], enc_password: row[3], id: row[0])
  end

  def website=(new_website)
    raise ArgumentError, 'Website can not be empty' if new_website.empty?

    @website = new_website
  end

  def username=(new_username)
    raise ArgumentError, 'Username can not be empty' if new_username.empty?

    @username = new_username
  end

  # Encrypt and store new password
  def update_password(new_password, master_password)
    raise ArgumentError, 'Password can not be empty' if new_password.empty?

    @enc_password = PasswordCipher.encrypt(new_password, master_password)
  end

  def reencrypt_password(master_password, new_master_password)
    password = get_password(master_password)
    update_password(password, new_master_password)
  end

  # Decrypt stored pasword data using master password
  def get_password(master_password)
    PasswordCipher.decrypt(@enc_password, master_password)
  end
end
