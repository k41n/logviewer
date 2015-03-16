class AuditEvent < ActiveRecord::Base
  def self.analyze_log_files
    #%w(frontend_audit support_audit db_audit app_audit).each do |file_name|
    %w(support_audit front_audit app_audit db_audit).each do |file_name|
      analyze_log_file(file_name)
    end
  end

  def self.analyze_log_file(file_name)
    File.open("analyzed_logs/#{file_name}_diff.log") do |f|
      str = f.gets
      while str do
        #if str =~ /CRED_DISP/ && str =~ /sshd/
        #  new(server_name: file_name, kind: 'logout').save_params(str)
        if str =~ /USER_ACCT/ && str =~ /sshd/
          ts = DateTime.strptime(str.match(/msg=audit([0-9]*.*)/)[1].delete("()"), '%s')
          new(server_name: file_name, kind: 'successful_login').save_params(str, ts)
        elsif str =~ /USER_LOGIN/ && str =~ /sshd/ && str =~ /res=failed/ && str !~ /acct=(28756E6B6E6F776E207573657229|28696E76616C6964207573657229)/
          new(server_name: file_name, kind: 'failed_login').save_params(str, ts)
        end
        str = f.gets
      end
    end
  end

  def save_params(str, ts)
    ip = str.match(/addr=(?<ip>.*?) /)[:ip]
    if kind == 'failed_login' || ip != '?'
      self.user_name = str.match(/acct="(?<user_name>.*?)"/)[:user_name]
      self.ip = ip
      self.time_moment = ts
      save
    end
  end
end
