require 'moat/command'
require 'moat/rules'

require 'rubygems'
require 'file/tail'
require 'socket'
require 'yaml'

module Moat
  class Moat
    def initialize(config_file, auth_log)
      @auth_log = auth_log
    
      conf = YAML::load(File.open(config_file))
      @startup_actions = Command.new_cmd_array(conf['startup'])
      
      action_map = {}
      [ Whitelister, Blacklister ].each do |action_type|
        action = action_type.new(conf)
        action_map[action.name_in_conf] = action
      end
      
      @rules = []
      conf['rules'].each do |rule|
        action = action_map[rule['action']]
        raise "Config error: No such action \"#{rule['action']}\" for rule: #{rule}" unless action
        @rules << action.new_rule(rule)
      end
    end

    def run
      LOGGER.info "--------------------------------"
      LOGGER.info "filling moat"
      @startup_actions.each{ |cmd| cmd.execute(LOGGER) }
      LOGGER.info "moat ready"
      
      File::Tail::Logfile.tail(@auth_log, :max_interval => 2, :backward => 100) do |line|
        line.strip!
        begin
          @rules.each do |rule|
            break if rule.apply(line)
          end
        rescue => error
          LOGGER.error "Error: #{error} - caused by log line: #{line}" + error.backtrace.join("\n  ")
        end
      end
    end
  end
end