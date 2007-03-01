require 'moat/command'
require 'moat/util'

module Moat
private

  # A pattern-based rule.
  
  class Rule
    def initialize(conf, &action)
      raise "Config error: no pattern specified for rule: #{conf}" unless conf['pattern']
      @pat = Regexp.new(conf['pattern'])
      @action = action
    end
    
    # Applies the rule action if the given log line matches the rule's pattern.
    
    def apply(log_line)
      if @pat =~ log_line
        @action.call(log_line, $1)
        return true
      else
        return false
      end
    end
  end
  
  # A factory for whitelist rules.
  
  class Whitelister
    def initialize(conf)
      @whitelisted = {}
      @whitelist_actions = Command.new_cmd_array(conf['whitelist'])
    end
    
    def name_in_conf
      "whitelist"
    end
    
    def new_rule(conf)
      Rule.new(conf) do |line, host|
        ip = ::Moat.resolve_ip(host)
        if !@whitelisted.include?(ip)
          @whitelisted[ip] = nil
          LOGGER.warn "Whitelisting #{ip}: #{line}"
          @whitelist_actions.each do |cmd|
            cmd.execute(:ip => ip)
          end
        end
      end
    end
  end
  
  # A factory for blacklist rules.
  
  class Blacklister
    def initialize(conf)
      @blacklisted = {}
      @scoreboard = Hash.new(0.0)
      @blacklist_actions = Command.new_cmd_array(conf['blacklist'])
      @blacklist_threshold = conf['blacklist_threshold']
    end
    
    def name_in_conf
      "strike"
    end
    
    def new_rule(conf)
      score = conf['score']
      Rule.new(conf) do |line, host|
        ip = ::Moat.resolve_ip(host)
        total = @scoreboard[ip] += score
        LOGGER.info "Total for #{ip} is #{total}: #{line}"
        if total >= @blacklist_threshold && !@blacklisted.include?(ip)
          @blacklisted[ip] = nil
          LOGGER.warn "Blacklisting #{ip}"
          @blacklist_actions.each do |cmd|
            cmd.execute(:ip => ip)
          end
        end
      end
    end
  end
end