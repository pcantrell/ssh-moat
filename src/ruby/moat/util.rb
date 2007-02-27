module Moat
    def self.resolve_ip(host)
        raise "Empty host; your regexp may not match the auth log format" if host =~ /^\s*$/
        return host if host =~ /^((\d+)\.(\d+)\.(\d+)\.(\d+)|([\dA-F:]+))$/i
        ip = Socket.getaddrinfo(host, 0)[0][3]
        raise "Unable to resolve ip for #{host}" unless ip
        return ip
    end    
end
