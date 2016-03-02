require 'rubygems'
require 'mysql2'

DB_SOCKET = '/var/lib/mysql/mysql.sock'
DB_NAME = 'logger'
DB_USER = 'logger'
DB_PASS = 'logger'
ALERT_COUNT = 10

@db = Mysql2::Client.new(socket: DB_SOCKET, username: DB_USER, password: DB_PASS, database: DB_NAME)

check_date = (Time.now - 86400).strftime("%Y-%m-%d")
rst = @db.query("SELECT COUNT(id) AS count FROM penetrations WHERE priority=1 AND created_at >= '#{ check_date }'")

if rst.first['count'].to_i >= ALERT_COUNT
  `echo 'За #{check_date} обнаружено #{ rst.first['count'] } атак.' | mail -s "SNORT alert. Many attacks detected." 'rt@onpay.ru, andrei.malyshev@kodep.ru'`
end
