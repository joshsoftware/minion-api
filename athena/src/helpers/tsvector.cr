require "string_scanner"

module MinionAPI::Helpers
  struct MatchClause
    property phrase : String
    property conjunction : String?

    def initialize(@phrase, @conjunction); end
  end

  def self.parse_input_to_tsv(input : String) : String
    # This will take a string, and transform it into a valid postgresql tsquery.
    # "www* and not GET" == "www:* & !GET"
    # "PC Driver has requested exit" == "PLC <-> Driver <-> has <-> requested <-> exit"
    # "handshake fail* and mylab" = "handshake <-> fail:* & mylab"
    # "rout* and not qav2-router-1-nyc1" "rout:* & ! qav2-router-1-nyc1"

    # Substitute and/or/not
    input = input.gsub(/\b(and|or|not)\b/i) do |mtch|
      case mtch.downcase
      when "and"
        "&"
      when "or"
        "|"
      when "not"
        "!"
      end
    end

    # Substitute prefix matching
    input = input.gsub(/(\w)\*(\s|$)/, "\\1:*\\2")

    # Substitute follows matching
    input = input.gsub(/\b(\s+)\b/) { " <-> " }

    return input
  end

  # "haproxy phpunit" == "%haproxy%phpunit%"
  # "haproxy and phpunit" == "%haproxy% AND %phpunit%"
  # This would be much better with some real parsing instead of this cheap knock-off
  def self.parse_input_to_ilike(input : String, field : String, args : MinionAPI::Helpers::SQLArgs) : String
    scnr = StringScanner.new(input)

    clauses = [] of MatchClause
    while chunk = scnr.scan_until(/(and|not|or)/i)
      mtch = chunk.match(/^(.*?)\s+(and|or|not)$/)
      if mtch.nil?
        next
      else
        clauses << MatchClause.new(mtch[1], mtch[2])
      end
    end
    clauses << MatchClause.new(scnr.rest, nil)

    sql = [] of String
    sql << "(\n"
    clauses.each do |clause|
      sql << "( #{field} ilike '%#{args.arg = clause.phrase.tr(" ", "%")}%' ) #{clause.conjunction.to_s.upcase}\n".gsub(/%+/, "%")
    end
    sql << ")"

    sql.join
  end
end
