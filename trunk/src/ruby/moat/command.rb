module Moat
    private
    
    class Command
        def initialize(cmd_line)
            raise "cmd_line is nil" unless cmd_line
            @cmd_line = cmd_line
        end

        def self.new_cmd_array(cmd_lines)
            cmd_lines.map{ |cmd| Command.new(cmd) }
        end
        
        def execute(logger, vars = {})
            # substitute variables
            cmd_line = @cmd_line.gsub(/\$\{([^}]+)\}/) do
                vars[$1.intern] || raise("No such variable ${#{$1}}")
            end

            # execute
            cmd_line.untaint
            cmd_out = `#{cmd_line} 2>&1`

            # check result
            if $? == 0
                logger.log "#{cmd_line}"
            else
                logger.log "command failed"
                logger.log "    cmd: #{cmd_line}"
                logger.log "    out: #{cmd_out}"
            end
        end
    end
end