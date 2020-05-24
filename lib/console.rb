module Minion
  module Console
    def self.start
      puts "Welcome to the Minion application console (based on 'pry')."
      Pry.start
    end
  end
end
