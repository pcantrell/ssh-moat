module Moat
  private
  
  # A command line with optional named parameters that can be invoked repeatedly.
  # For example:
  #
  #  cmd = Command.new("mkdir ${dir}")
  #  cmd.execute(:dir => "/tmp/foo")
  #  cmd.execute(:dir => "/tmp/bar")
  
  class Command
    def initialize(cmd_line)
      raise "cmd_line is nil" unless cmd_line
      @cmd_line = cmd_line
    end

    def self.new_cmd_array(cmd_lines)
      cmd_lines.map{ |cmd| Command.new(cmd) }
    end
    
    def execute(vars = {})
      # substitute variables
      cmd_line = @cmd_line.gsub(/\$\{([^}]+)\}/) do
        vars[$1.intern] || raise("No such variable ${#{$1}}")
      end

      # execute
      cmd_line.untaint
      cmd_out = `#{cmd_line} 2>&1`

      # check result
      if $? == 0
        LOGGER.info "#{cmd_line}"
      else
        LOGGER.error "command failed"
        LOGGER.error "  cmd: #{cmd_line}"
        LOGGER.error "  out: #{cmd_out.strip}"
      end
    end
  end
end