module Protobox
  module Commands
    extend self

    STOCK_COMMANDS = %w[install switch]
    CUSTOM_COMMANDS = %w[init]

    def run(args)
      args.unshift 'help' if args.empty?

      # get first argument
      cmd = args[0]

      # commands can have dashes
      cmd = cmd.gsub(/(\w)-/, '\1_')

      if STOCK_COMMANDS.include?(cmd)
        send("pass", args)
      elsif method_defined?(cmd) and cmd != 'run' and cmd != 'pass'
        args.shift
        send(cmd, args)
      else
        send("help", args)
      end
    rescue Errno::ENOENT
      if $!.message.include? "No such file or directory - vagrant"
        abort "Error: `vagrant` command not found"
      else
        raise
      end
    rescue Errors::Error => err
      abort "Error: #{err.message}"
    end

    # $ protobox init
    def init(args)
      require_relative 'command/init'
      Command::Init.execute(args)
    end

    # $ protobox help
    def help(args)
      require_relative 'command/help'
      Command::Help.execute(args)
    end

    # $ protobox version
    def version(args)
      puts Protobox::VERSION
    end

    # pass through
    def pass(args)
      require_relative 'command/passthrough'
      Command::PassThrough.execute(args)
    end

  end
end