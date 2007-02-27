require 'moat/command'
require 'moat/util'

module Moat
private
    class Rule
        def initialize(conf, &action)
            raise "Config error: no pattern specified for rule: #{conf}" unless conf['pattern']
            @pat = Regexp.new(conf['pattern'])
            @action = action
        end
        
        def apply(log_line)
            if @pat =~ log_line
                @action.call(log_line, $1)
                return true
            else
                return false
            end
        end
    end
    
    class Whitelister
        def initialize(conf)
            @whitelisted = {}
            @whitelist_actions = Command.new_cmd_array(conf['whitelist'])
        end
        
        def name_in_conf
            "whitelist"
        end
        
        def new_rule(conf, logger)
            Rule.new(conf) do |line, host|
                ip = ::Moat.resolve_ip(host)
                if !@whitelisted.include?(ip)
                    @whitelisted[ip] = nil
                    logger.log "Whitelisting #{ip}: #{line}"
                    @whitelist_actions.each do |cmd|
                        cmd.execute(logger, :ip => ip)
                    end
                end
            end
        end
    end
    
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
        
        def new_rule(conf, logger)
            score = conf['score']
            Rule.new(conf) do |line, host|
                ip = ::Moat.resolve_ip(host)
                total = @scoreboard[ip] += score
                logger.log "Total for #{ip} is #{total}: #{line}"
                if total >= @blacklist_threshold && !@blacklisted.include?(ip)
                    @blacklisted[ip] = nil
                    logger.log "Blacklisting #{ip}"
                    @blacklist_actions.each do |cmd|
                        cmd.execute(logger, :ip => ip)
                    end
                end
            end
        end
    end
end