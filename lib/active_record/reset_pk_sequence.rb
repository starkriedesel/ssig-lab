module ActiveRecord
  class Base
    def self.reset_pk_sequence
      case ActiveRecord::Base.connection.adapter_name
      when 'SQLite'
        new_max = maximum(primary_key) || 0
        update_seq_sql = "UPDATE sqlite_sequence SET seq='#{new_max}' WHERE name='#{table_name}'"
        ActiveRecord::Base.connection.execute update_seq_sql
      when 'Mysql2'
        ActiveRecord::Base.connection.execute "ALTER TABLE `#{table_name}` AUTO_INCREMENT = 1"
      when 'PostgreSQL'
        ActiveRecord::Base.connection.reset_pk_sequence! table_name
      else
        raise 'Task not implemented fro this DB adapter'
      end
    end
  end
end