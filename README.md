# Rubikey
Text based local password manager built in Ruby allowing for secure password generation and storage.

* https://github.com/wtweber/Rubikey/tree/main

## How to install `Rubikey`
* bundle install

## How to use `Rubikey`
* bundle exec ruby bin/rubikey

## How to run tests for `Rubikey`
* bundle exec rspec
* also comes with coverage file in coverage/index.html

## `Rubikey` features
* Store Password
* Retrieve password
* Search for passwords
* Generate password
* Set master password
* Change master password

## Limitations

## Other
* Rubocop ignores "Prefer String Interpolation to String Concatenation"
    * The formatting for textcoloring / textstyles is much easier to read in Visual Studio Code because it [TextColor] is highlighted in a different color and also takes less special characters to write than string interpolation.
## Authors
* Will Weber <wtweber@tamu.edu>
* Caleb Austin <calebaustin01@tamu.edu>
