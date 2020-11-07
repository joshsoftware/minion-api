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

  def self.list_of_where_by_data_key(criteria_key, query_criteria) : Array(Tuple(String, String))
    sqls = [] of Tuple(String, String)

    query_criteria.each do |criteria|
      next unless criteria["criteria"] == criteria_key

      sqls << {criteria["value"], "AND data_key = '#{criteria["value"]}'"}
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
end
