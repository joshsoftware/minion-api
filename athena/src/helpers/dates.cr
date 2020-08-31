require "minion-common/minion/parse_date"

module MinionAPI::Helpers
  # TODO: This method has nothing to do with dates. Move it to a
  # separate file.
  def self.list_of_where_by_json_key(field, criteria_key, query_criteria) : Array(Tuple(String, String))
    sqls = [] of Tuple(String, String)

    query_criteria.each do |criteria|
      next unless criteria["criteria"] == criteria_key

      sqls << {criteria["value"], "AND #{field} ? '#{criteria["value"]}'"}
    end

    sqls
  end

  # TODO: This method has nothing to do with dates. Move it to a
  # separate file.
  def self.where_by_json_key(field, criteria_key, query_criteria) : String
    sql = [] of String

    query_criteria.each do |criteria|
      next unless criteria["criteria"] == criteria_key

      sql << "AND #{field} ? '#{criteria["value"]}'"
    end

    "(#{sql.join("\n")})"
  end

  def self.where_by_date(field, query_criteria) : String
    sql = [] of String

    query_criteria.each do |criteria|
      modified_value = criteria["value"].gsub(/T(\d+:\d+)$/, " \\1:00")

      debug!("Converting #{criteria["value"]} to #{modified_value}")

      orig = Minion::ParseDate.parse(criteria["value"])
      mod = Minion::ParseDate.parse(modified_value)

      debug!("#{orig} to #{mod}")
      if orig != mod
        criteria["value"] = mod.to_s
      end
    end

    debug!("Timestamp args: #{query_criteria.inspect}")

    timestamp_keys = query_criteria.map { |e| e["criteria"].downcase }
    before_count = timestamp_keys.select { |k| k == "before" }.size
    after_count = timestamp_keys.select { |k| k == "after" }.size

    debug!("#{before_count} <=> #{after_count}")

    if before_count > 0 && after_count > 0
      sql << date_between(field, query_criteria)
      query_criteria.each { |arg| sql << date_on(field, arg) }
    else
      query_criteria.each do |arg|
        debug!("date before or after(#{arg.inspect})")
        sql << date_before_or_after(field, arg)
        sql << date_on(field, arg)
      end
    end

    debug!("Timestamp SQL: #{sql.inspect}")
    sql.reject(&.empty?).join
  end

  def self.date_between(field, args)
    before = [nil, Minion::ParseDate.parse("9999-01-01")] of String? | Time
    after = [nil, Minion::ParseDate.parse("0001-01-01")] of String? | Time
    args.each do |arg|
      parsed_date = Minion::ParseDate.parse(arg["value"])
      if !parsed_date.nil? && arg["criteria"] == "before" && before[1].not_nil!.as(Time) > parsed_date
        before[0] = arg["criteria"]
        before[1] = parsed_date
      elsif !parsed_date.nil? && arg["criteria"] == "after" && after[1].not_nil!.as(Time) < parsed_date
        after[0] = arg["criteria"]
        after[1] = parsed_date
      end
    end

    before_cast, before_parsed_date = parse_and_cast_date_value(before[1].as(Time))
    after_cast, after_parsed_date = parse_and_cast_date_value(after[1].as(Time))

    if before_parsed_date && after_parsed_date
      "AND #{field} BETWEEN '#{after_parsed_date}' AND '#{before_parsed_date}'\n"
    else
      ""
    end
  end

  def self.date_before_or_after(field, arg)
    cast, parsed_date = parse_and_cast_date_value(Minion::ParseDate.parse(arg["value"]))

    debug!(parsed_date)
    if parsed_date && arg["criteria"] == "before"
      "AND #{field}#{cast} < '#{parsed_date}'\n"
    elsif parsed_date && arg["criteria"] == "after"
      "AND #{field}#{cast} > '#{parsed_date}'\n"
    else
      ""
    end
  end

  def self.date_on(field, arg)
    cast, parsed_date = parse_and_cast_date_value(Minion::ParseDate.parse(arg["value"]))

    # TODO: This fails if there is more than one "on" date. The handling is
    # too simplistic.
    if parsed_date && arg["criteria"] == "on"
      "AND #{field}#{cast} = '#{parsed_date}'\n"
    else
      ""
    end
  end

  def self.parse_and_cast_date_value(parsed_date : Time?)
    debug!("parse_and_cast_date_value: #{parsed_date.inspect}")
    return {"", nil} unless parsed_date

    formatted_date = parsed_date.to_s("%Y-%m-%d %H:%M:%S")
    cast = ""
    if formatted_date =~ /00:00:00/
      cast = "::date"
      formatted_date = parsed_date.to_s("%Y-%m-%d")
    end

    {cast, formatted_date}
  end
end
