class Penetration < ActiveRecord::Base
  def self.analyze_log_files(year)
    #%w(frontend_audit support_audit db_audit app_audit).each do |file_name|
    %w(support front app db log).each do |file_name|
      analyze_log_file(file_name, year)
    end
  end

  def self.analyze_log_file(file_name, year)
    File.open("analyzed_logs/#{file_name}_snort_diff.log") do |f|
      str = f.gets
      while str do
        if str[0..3] == '[**]'
          vulnerability = str.match(/\d\] (?<vulnerability>.*?) \[/)[:vulnerability]
          pstr = f.gets
          priority = pstr.match(/Priority: (?<prio>\d+?)/)[:prio]
          str = f.gets
          create(server_name: file_name,
                 vulnerability: vulnerability,
                 attacker_ip: str.match(/\d (?<attacker_ip>.*?) ->/)[:attacker_ip],
                 attacked_ip: str.match(/-> (?<attacked_ip>.*?)$/)[:attacked_ip],
                 time_moment: DateTime.parse("#{year}/#{str[0..13]}"),
                 priority: priority.to_i)
        end
        str = f.gets
      end
    end
  end
end
