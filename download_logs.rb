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

    Net::SCP.start(sl['host'], sl['user'], port: sl['port']) do |scp|
      sl['files'].each do |f|
        scp.download!("#{f['dest_path']}.bz2", dest_dir)
        logfile_path = dest_dir + File.basename(f['dest_path'])
        `bzip2 -df #{logfile_path}.bz2`
        f['amount_of_lines'] += `wc -l #{logfile_path}`.split(' ')[0].to_i unless f['entire']
      end
    end

    sl['files'].each { |f| ssh.exec!("rm #{f['dest_path']}.bz2") }
  end
end

File.open(yml_file, 'w') { |f| f.write(server_logs.to_yaml) }
