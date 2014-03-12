require 'optparse'

module Protobox
  module Command
    class Init
      def self.execute args
        options = { verbose: false }

        opts = help

        # Parse the options
        argv = opts.parse(args)
        #return if !argv

        #if argv.empty? || 
        if argv.first == 'help'
          puts opts
          exit
        end

        install_folder = Util::System.current_dir
        git = Util::Platform.git
        vagrant = Util::Platform.vagrant

        # Get installation folder
        puts "Protobox will now be installed at:"
        puts current_dir

        #install_folder = Protobox::Util::Input.get_input
        Util::Input.enter_or_abort # if STDIN.tty?

        # Check for git
        if !git
          raise Errors::FatalError, 'GIT is required'
        end

        # Check for vagrant
        if !vagrant
          raise Errors::FatalError, 'Vagrant is required'
        end

        # Check for previous installation
        if !Dir["#{install_folder}/.git/*"].empty?
          raise Errors::FatalError, <<-MESSAGE
          It appears something is already installed here. Please run this installer in an empty directory.
          MESSAGE
        end

        # Test for permissions
        if File.directory?(install_folder) and not File.executable?(install_folder)
          raise Errors::FatalError, <<-MESSAGE
          The installation folder, #{install_folder}, exists but is not readable. Please fix 
          the permissions and try again:
            sudo chmod 755 #{install_folder}
          MESSAGE
        end

        puts "Starting installation..."

        if File.directory?(install_folder)
          system "/bin/chmod g+rwx #{install_folder}"
        else
          system "/bin/mkdir #{install_folder}"
          system "/bin/chmod g+rwx #{install_folder}"
        end

        puts "Downloading and installing protobox..."
        Dir.chdir(install_folder) do
          if git
            # we do it in four steps to avoid merge errors when reinstalling
            system git, "init", "-q"
            system git, "remote", "add", "origin", "https://github.com/protobox/protobox"

            args = git, "fetch", "origin", "master:refs/remotes/origin/master", "-n"
            args << "--depth=1" if ARGV.include? "--fast"
            system *args

            system git, "reset", "--hard", "origin/master"
          else
            # -m to stop tar erroring out if it can't modify the mtime for root owned directories
            # pipefail to cause the exit status from curl to propogate if it fails
            # we use -k for curl because Leopard has a bunch of bad SSL certificates
            #curl_flags = "fsSL"
            #curl_flags << "k" if macos_version <= "10.5"
            #system "/bin/bash -o pipefail -c '/usr/bin/curl -#{curl_flags} https://github.com/protobox/protobox/tarball/master | /usr/bin/tar xz -m --strip 1'"
          
            raise Errors::FatalError, "GIT not found and is required to install"
          end
        end

        puts "Configuring protobox..."

        Dir.chdir(install_folder) do
          system "/bin/cp data/config/common.yml-dist data/config/common.yml"

          #system "vagrant up" if ARGV.include? "--boot"
        end

        # Install vagrant tools
        system vagrant, "plugin", "install", "vagrant-protobox"

        # TODO
        # - check for arguments to install a config and boot
        # - protobox init abc123
        # - this, sets up protobox dir in current directory
        # - installs vagrant plugin
        # - passes through vagrant install command
        # - vagrant up

        puts "Installation successful! Type the following to make sure its working: "
        #puts "cd #{install_folder}/ && protobox help"
        puts "protobox help"

        #Cli.exec("protobox help")

        # Success, exit status 0
        0
      end

      def self.help 
        return OptionParser.new do |o|
          o.banner = "Usage: protobox init [options]"
          o.separator ""
          o.separator "Options:"
          o.separator ""

          o.on("-c", "--clean", "Clean any temporary download files") do |c|
            options[:clean] = c
          end

          o.on("-f", "--force", "Overwrite an existing box if it exists") do |f|
            options[:force] = f
          end

          o.on("--verbose", "Enable verbose output for the installation") do |v|
            options[:verbose] = v
          end

          o.separator ""
        end
      end
    end
  end
end