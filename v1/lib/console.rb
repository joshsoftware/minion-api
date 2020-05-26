module Minion
  module Console
    def self.start
      puts "Welcome to the Minion application console (based on 'pry')."
      Pry.start
    end
  end
end

# To create a new command, here's some ruby you can copy/paste into the console:
#   Command.create(JSON.parse(File.read("./test/new_command.json")))
