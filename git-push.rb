#!/usr/bin/env ruby
require 'open3'
require 'optparse'

BOLD = "\e[1m"
RED = "\e[31m"
GREEN = "\e[32m"
YELLOW = "\e[33m"
CLEAR = "\e[0m"
CL = CLEAR

OK = "[ OK ]"
WARN = "[ WARN ]"
FATAL = "[ FATAL ]"

# ==============================

def sh(command)
  stdout, stderr, process = Open3.capture3(command)
  if @quiet == true
    @quiet = false
    puts command
    puts stdout

    if stderr
      puts stderr
    end
  end

  @sh_err = stderr
  return stdout
end

# ==============================

OPTS = {}
opt = OptionParser.new do |opt|
  opt.on('-m VAL'){|v| OPTS[:m] = v}
  opt.on('-add VAL'){|v| OPTS[:add] = v}
  opt.on_tail("-h", "--help", "") do |v|
    script_name = File.basename($0)
    opt.banner =
      ("#{GREEN}[Usage]#{CL}: #{BOLD}git-push#{CL} [mode] #{BOLD}-m#{CL} [message] ( #{BOLD}-add#{CLEAR} [option] )" +
      "\n\n  * #{BOLD}-add#{CL} [option] is used for `git add`")
    puts opt.banner
    # puts opt
    exit
  end
  opt.parse!(ARGV)
end

target = ARGV[0]
message = OPTS[:m]
add = OPTS[:add]

# if not initialized
nogit = (Dir.exists?(".git") == false)

if nogit
  puts "#{RED}#{FATAL} Current dir is not initialized!#{CLEAR}"
  puts "#{RED} --> Please type `git init`#{CLEAR}"
  exit 1
end

puts "#{GREEN}#{OK} '.git' exists#{CL}"

if target == 'push' || target == 'commit'
  puts "#{GREEN}#{OK} Mode: #{target}#{CL}"
  if message == nil
    puts "#{RED}#{FATAL} Commit message is empty#{CL}"
    exit 1
  else
    puts "#{GREEN}#{OK} Commit message is ok#{CL}"
    if add == nil
      puts "#{YELLOW}#{WARN} -add is empty#{CL}"
      puts "#{YELLOW}#{WARN} set `git add --all`#{CL}"
      add = "--all"
    end

    sh("git add #{add}")
    if target == 'commit' || target == 'push'
      sh("git commit -m #{message}")
    end
    if target == 'push'
      sh("git push -u origin master")
    end
  end
else
  puts "#{RED}[FATAL] Select valid mode#{CLEAR}"
  exit 1
end
