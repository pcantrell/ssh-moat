Monitors the SSH authorization log, and directs firewall software (ipfw by default) to blacklist IPs which are exhibiting suspicious behavior, and whitelist IPs which make successful logins. You can use it to greatly increase the time necessary for a cracker to mount a successful dictionary attack on your server.

The utility is configurable, so it can be used to monitor any log (not just SSH) for any good / bad behavior patterns, and take any command-line action as a response.

Developed and tested on Mac OS X, but should work just fine on any UNIX with Ruby installed.