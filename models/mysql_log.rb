require 'time'
require 'ipaddr'
require 'json'

class MysqlLog < ActiveRecord::Base
  def self.analyze_log_files
    %w(db_mysql_audit).each do |file_name|
      analyze_log_file(file_name)
    end
  end

  def self.analyze_log_file(file_name)
    File.open("analyzed_logs/#{file_name}_diff.log") do |f|
      str = f.gets
      while str do
          ar = JSON.parse(str)['audit_record']
	  puts ar
          case ar['name']
            when 'Query'
	      puts "-- Quer #{ar}"
              unless ar['user'].gsub(' ','') == 'scoring[scoring]@[192.168.0.2]'
                create(
                  action: ar['name'].strip,
                  action_time: Time.parse(ar['timestamp']),
                  connection_id: ar['connection_id'].to_i,
                  state: ar['status'].to_i,
                  user: ar['user'].strip,
                  query: ar['sqltext'].strip,
                  ip: ar['ip'].strip,
                )
              end
            when 'Connect', 'Quit'
	      puts "-- C:Q #{ar}"
              create(
                action: ar['name'].strip,
                action_time: Time.parse(ar['timestamp']),
                connection_id: ar['connection_id'].to_i,
                state: ar['status'].to_i,
                user: ar['user'].strip,
                host: ar['host'].strip,
                ip: ar['ip'].strip,
                db: ar['db'].strip
              )
          end      
        str = f.gets
      end
    end
  end

end
