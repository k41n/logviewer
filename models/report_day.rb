class ReportDay < ActiveRecord::Base
  require 'time'
  has_many :aide_changes

  def self.analyze_log_files
    ReportDay.transaction do
      ReportDay.delete_all
      AideChange.delete_all

      %w(support_aide front_aide app_aide db_aide log_aide).each do |file_name|
        analyze_log_file(file_name)
      end
    end
  end

  def self.analyze_log_file(file_name)
    report_day = new(server_name: file_name)
    File.open("analyzed_logs/#{file_name}_diff.log") do |f|
      str = f.gets
      while str do
        if match_data = str.match(/^(changed|added|removed):.*/)
          action, file = match_data.to_s.split(': ')
          report_day["total_#{action}"] += 1
          report_day.aide_changes.new({ file_name: file, action: AideChange::ACTIONS[action.to_sym] })
        elsif timestamp_data = str.match(/^Start timestamp:.*/)
          report_day.time_moment = Time.parse(timestamp_data.to_s.split(': ')[1])
        end
        str = f.gets
      end
    end
    report_day.save
  end

end
