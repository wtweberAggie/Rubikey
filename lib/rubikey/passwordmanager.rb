# frozen_string_literal: true

require_relative 'masterpassword'
require 'sqlite3'

# PasswordManager class to store and handle passwords in an sql database for retrieval
class PasswordManager
  attr_reader :master_password

  def initialize(master_password:, new_password: false)
    MasterPassword.store(master_password) if new_password
    @master_password = MasterPassword.new(master_password)

    # Create and setup the SQL database to store password data
    @database = SQLite3::Database.new('pw.db')
    create_database_table
  end

  # Create SQL database table for passwords
  def create_database_table
    @database.execute <<-SQL
    CREATE TABLE IF NOT EXISTS passwords (
      id INTEGER PRIMARY KEY,
      website TEXT,
      username TEXT,
      enc_password TEXT
      );
    SQL
  end

  # Insert new instance of a password into the database
  def add_password(password)
    @database.execute('INSERT INTO passwords (website, username, enc_password) VALUES (?, ?, ?)',
                      [password.website, password.username, password.enc_password])
    password.id = @database.last_insert_row_id
  end

  def update_password(password)
    @database.execute('INSERT OR REPLACE INTO passwords (id, website, username, enc_password) VALUES (?, ?, ?, ?)',
                      [password.id, password.website, password.username, password.enc_password])
  end

  # Get password by ID from database
  def get_password_with_id(id)
    Password.new_from_db(@database.execute('SELECT * FROM passwords WHERE id = ?', id).first)
  end

  # Get passwords for specific website
  def get_passwords_for(site)
    @database.execute('SELECT * FROM passwords WHERE website = ?', site).map { |row| Password.new_from_db(row) }
  end

  # Get all passwords from database
  def all_passwords
    @database.execute('SELECT * FROM passwords').map { |row| Password.new_from_db(row) }
  end

  # Delete a specific Password instance from the database
  def remove_password(password)
    @database.execute('DELETE FROM passwords WHERE id = ?', password.id)
  end

  alias delete_password remove_password

  # Close the database connection so the database file can be moved or deleted
  def close
    @database.close unless @database.closed?
  end

  def change_master_password(master_password, new_master_password)
    raise ArgumentError, 'Master Password is incorrect.' unless @master_password.auth(master_password)

    all_passwords.each do |pw|
      new_pw = pw
      new_pw.reencrypt_password(master_password, new_master_password)
      update_password(new_pw)
    end
    @master_password.update(master_password, new_master_password)
  end
end
