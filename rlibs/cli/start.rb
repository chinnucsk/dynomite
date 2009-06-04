options = {}
options[:port] = "-dynomite port 11222"
options[:databases] = ''
options[:config] = '-dynomite config "config.json"'
options[:startup] = "-run dynomite start"

OptionParser.new do |opts|
  opts.banner = "Usage: dynomite start [options]"

  contents =  File.read(File.dirname(__FILE__) + "/shared/common.rb")
  eval contents

  opts.separator ""
  opts.separator "Specific options:"

  opts

  opts.on("-c", "--config [CONFIGFILE]", "path to the config file") do |config|
    options[:config] = %Q(-dynomite config "\\"#{config}\\"")
  end

  opts.on("-l", "--log [LOGFILE]", "error log path") do |log|
    options[:log] = %Q[-kernel error_logger '{file,"#{File.join(log, 'dynomite.log')}"}' -sasl sasl_error_logger '{file,"#{File.join(log, 'sasl.log')}"}']
  end

  opts.on('-j', "--join [NODENAME]", 'node to join with') do |node|
    options[:jointo] = %Q(-dynomite jointo "'#{node}'")
  end

  opts.on('-d', "--detached", "run detached from the shell") do |detached|
    options[:detached] = '-detached'
  end

  opts.on('-p', "--pidfile PIDFILE", "write pidfile to PIDFILE") do |pidfile|
    options[:pidfile] = %Q(-dynomite pidfile "'#{pidfile}'")
  end
end.parse!

cookie = Digest::MD5.hexdigest(options[:cluster] + "NomMxnLNUH8suehhFg2fkXQ4HVdL2ewXwM")

str = "erl \
  -boot start_sasl \
  +K true \
  +A 30 \
  +P 60000 \
  -smp enable \
  -pa #{ROOT}/ebin/ \
  -pa #{ROOT}/deps/mochiweb/ebin \
  -pa #{ROOT}/deps/rfc4627/ebin \
  -pa #{ROOT}/deps/thrift/ebin \
  -sname #{options[:name]} \
  #{options[:log]} \
  #{options[:config]} \
  #{options[:jointo]} \
  -setcookie #{cookie} \
  #{options[:startup]} \
  #{options[:detached]} \
  #{options[:pidfile]} \
  #{options[:profile]}"
puts str
exec str

  #  -boot #{ROOT}/releases/0.5.0/dynomite_rel \
