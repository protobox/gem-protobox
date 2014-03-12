module Protobox
  module Command
    class Help
      def self.execute args
      	global = <<-help
usage: protobox [options] <command> [<args>]

Commands:
   version    Protobox CLI Version
   init       Create a new protobox install in the current directory
   install    Install a protobox configuration locallly
   switch     Switch the protobox configuration file to be used by vagrant

See 'protobox help <command>' for more information on a specific command.
help

        if args.empty?
          puts global
          exit
        end

        cmd = args.first

        system "protobox", cmd, "help"

        # Success, exit status 0
        0
      end
    end
  end
end