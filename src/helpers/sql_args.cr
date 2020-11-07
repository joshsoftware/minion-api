module MinionAPI::Helpers
  # This is a simple helper class to keep track of the arguments for a SQL
  # prepared statement, and to return the monotonically increasing PG $n
  # placekeepers for them.
  class SQLArgs
    property argn : Int32 = 0
    property argv : Array(String) = [] of String
    property offset : Int32 = 0

    def initialize(@offset = 0); end

    def arg=(val)
      @argv << val
      @argn += 1
      index
    end

    def index
      @offset + @argn
    end
  end
end
