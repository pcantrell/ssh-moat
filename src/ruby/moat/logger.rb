module Moat
    #! replace with some nice logging framework, maybe?
    class Logger
        def initialize(log_file)
            @log_file = log_file
        end

        def log(message)
            if @log_file
                File.open(@log_file, "a") do |f|
                    f.puts(format(message))
                end
            else
                puts(format(message))
            end
        end
        
    private
        def format(message)
            "#{Time.now}: #{message}"
        end
    end
end