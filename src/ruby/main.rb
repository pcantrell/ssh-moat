require 'moat/moat'

require 'rubygems'
require 'file/tail'
require 'socket'
require 'yaml'

# Parse args

def usage(message)
    puts message
    puts
    puts "options:"
    puts "   -c | --config   moat config file"
    puts "   -w | --watch    log file to watch (default: /var/log/auth.log)"
    puts "   -l | --log      moat log file, or - for stdout (default: /var/log/moat.log)"
    exit 1
end

def shift
    ARGV.delete_at(0)
end

auth_log = '/var/log/auth.log'
moat_log = '/var/log/moat.log'

while !ARGV.empty?
    arg = shift
    case arg
    when /-c|--config/
        conf = shift
    when /-w|--watch/
        auth_log = shift
    when /-l|--log/
        moat_log = shift
        moat_log = nil if moat_log == '-'
    else
        usage "moat: unknown option: #{arg}"
    end
end

usage "moat: must specify a config file" unless conf
usage "moat: must specify a log file to watch" unless auth_log

# Fire it up

Moat::Moat.new(conf, auth_log, moat_log).run
