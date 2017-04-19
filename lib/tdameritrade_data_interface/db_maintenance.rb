module DBMaintenance
  def self.vacuum_database
    ActiveRecord::Base.connection.execute "VACUUM FULL"
    ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
  end
end