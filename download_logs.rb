require 'yaml'
require 'net/ssh'
require 'net/scp'

yml_file = 'server_logs.yml'
server_logs = YAML.load_file(yml_file)
dest_dir = 'analyzed_logs/'

server_logs.each do |sl|
  Net::SSH.start(sl['host'], sl['user'], port: sl['port']) do |ssh|
    sl['files'].each do |f|
      if f['entire']
        ssh.exec("cat #{f['source_path']} | bzip2 > #{f['dest_path']}.bz2")
      else
        ssh.exec!("AMOUNT_OF_LINES=`cat #{f['source_path']} | wc -l`; tail -`expr $AMOUNT_OF_LINES - #{f['amount_of_lines']}` #{f['source_path']} | bzip2 > #{f['dest_path']}.bz2")
      end
    ssh.loop
    end

    attempt = 0
    while attempt < 2
      begin
        Net::SCP.start(sl['host'], sl['user'], port: sl['port']) do |scp|
          sl['files'].each do |f|
            scp.download!("#{f['dest_path']}.bz2", dest_dir)
            logfile_path = dest_dir + File.basename(f['dest_path'])
            `bzip2 -df #{logfile_path}.bz2`
            unless f['entire']
              if f['size'] && f['size'] >= 0
                new_size = ssh.exec!("ls -la #{f['source_path']}").split(' ')[4].to_i
                if new_size < f['size']
                  f['amount_of_lines'] = 0
                else
                  f['amount_of_lines'] += `wc -l #{logfile_path}`.split(' ')[0].to_i
                end
                f['size'] = new_size
              else
                f['amount_of_lines'] += `wc -l #{logfile_path}`.split(' ')[0].to_i
              end
            end
          end
        end
	attempt = 10
      #rescue
      # attempt = attempt + 1
      end
    end

    sl['files'].each { |f| ssh.exec!("rm #{f['dest_path']}.bz2") }
  end
end

a_file = File.open('/home/logger/scoring_log_viewer/analyzed_logs/auditd.log','w')

Net::SSH.start('83.222.116.91', 'root', port: 54378) do |ssh|
  log = ssh.exec!("bash -c '/sbin/aureport -f -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("LOG_SERVER: #{line}\n") if line[/\d{2}\/\d{2}\/\d{4}/] && line[/\d{2}\/\d{2}\/\d{4}/].size > 0 && !line.include?('?')
  end
end


Net::SSH.start('192.168.0.3', 'root', port: 54378) do |ssh|
  log = ssh.exec!("bash -c '/sbin/aureport -e --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("FRONT_SERVER: iptables changed #{line}\n") if line.include?('NETFILTER_CFG')
  end

  log = ssh.exec!("bash -c '/sbin/aureport -f -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("FRONT_SERVER: #{line}\n") if line[/\d{2}\/\d{2}\/\d{4}/] && line[/\d{2}\/\d{2}\/\d{4}/].size > 0 && !line.include?('?')
  end
end

Net::SSH.start('127.0.0.1', 'root', port: 54378) do |ssh|
  log = ssh.exec!("bash -c '/sbin/aureport -e -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("SUPPORT_SERVER: iptables changed #{line}\n") if line.include?('NETFILTER_CFG')
  end

  log = ssh.exec!("bash -c '/sbin/aureport -f -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("SUPPORT_SERVER: #{line}\n") if line[/\d{2}\/\d{2}\/\d{4}/] && line[/\d{2}\/\d{2}\/\d{4}/].size > 0 && !line.include?('?')
  end
end

Net::SSH.start('192.168.0.2', 'root', port: 54378) do |ssh|
  log = ssh.exec!("bash -c '/sbin/aureport -f -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("APP_SERVER: #{line}\n") if line[/\d{2}\/\d{2}\/\d{4}/] && line[/\d{2}\/\d{2}\/\d{4}/].size > 0 && !line.include?('?')
  end
end

Net::SSH.start('192.168.0.5', 'root', port: 54378) do |ssh|
  log = ssh.exec!("bash -c '/sbin/aureport -f -i --start this-month 0> /dev/null'").split("\n")
  log.each do |line|
    a_file.write("DB_SERVER: #{line}\n") if line[/\d{2}\/\d{2}\/\d{4}/] && line[/\d{2}\/\d{2}\/\d{4}/].size > 0 && !line.include?('?')
  end
end


a_file.close

File.open(yml_file, 'w') { |f| f.write(server_logs.to_yaml) }

`rsync -av --rsh='ssh -p54378' root@192.168.0.2:/var/www/railsapps/scoring/shared/log/VTB.log #{dest_dir}app_vtb.log`
`rsync -av --rsh='ssh -p54378' root@192.168.0.2:/var/www/railsapps/scoring/shared/log/mailer.production.log #{dest_dir}app_mailer.log`
`/usr/bin/scp -P 54378 /home/logger/scoring_log_viewer/bash_history_files/* root@83.222.116.91:/var/log/bash_histories/`
