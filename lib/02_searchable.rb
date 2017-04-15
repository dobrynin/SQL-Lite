require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    @past_searches = {} if @past_searches.nil?
    if @past_searches.include?(params)
      @past_searches[params]
    else
      where_line = params.keys.map { |key| "#{key} = ?" }.join(' AND ')
      results = DBConnection.execute(<<-SQL, params.values)
        SELECT
          *
        FROM
          #{table_name}
        WHERE
          #{where_line}
      SQL

      objects = parse_all(results)
      @past_searches[params] = objects
      objects
    end
  end
end

class SQLObject
  extend Searchable
end
