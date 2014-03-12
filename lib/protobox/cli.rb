module Protobox
  class Cli
    attr_reader :args
    
    def initialize(*args)
      #@args = Args.new(args)
      @args = args
    end

    # Shortcut
    def self.execute(*args)
      new(*args).execute
    end

    def execute
      Commands.run(@args)
    end

    # Runs multiple commands in succession; exits at first failure.
    def execute_command_chain commands
      commands.each_with_index do |cmd, i|
        if cmd.respond_to?(:call) then cmd.call
        elsif i == commands.length - 1
          # last command in chain
          STDOUT.flush; STDERR.flush
          exec(*cmd)
        else
          exit($?.exitstatus) unless system(*cmd)
        end
      end
    end

    # Special-case `echo` for Windows
    def exec *args
      if args.first == 'echo' && Util::Context.windows?
        puts args[1..-1].join(' ')
      else
        super
      end
    end

  end
end