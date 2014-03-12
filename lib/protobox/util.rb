require 'shellwords'

module Protobox
  module Util
    class Platform
      class << self

        def git
          @git ||= if ENV['GIT'] and File.executable?(ENV['GIT'])
            ENV['GIT']
          elsif Context.command?('git')
            'git'
          else
            s = `xcrun -find git 2>/dev/null`.chomp
            s if $? and not s.empty?
          end

          return unless @git

          # Github only supports HTTPS fetches on 1.7.10 or later:
          # https://help.github.com/articles/https-cloning-errors
          `#{@git} --version` =~ /git version (\d\.\d+\.\d+)/
          return if $1.nil? or $1 < "1.7.10"

          @git
        end

        def vagrant
          @vagrant ||= if ENV['VAGRANT'] and File.executable(ENV['VAGRANT'])
            ENV['VAGRANT']
          elsif Context.command?('vagrant')
            'vagrant'
          else
            s = `xcrun -find vagrant 2>/dev/null`.chomp
            s if $? and not s.empty?
          end

          return unless @vagrant

          @vagrant
        end

      end
    end

    class Input
      class << self

        def get_input 
          STDIN.gets.chomp
        end

        def get_char
          begin
            system("stty raw -echo")
            str = STDIN.getc
          ensure
            system("stty -raw echo")
          end
          str.chr
        end

        def enter_or_abort
          puts
          puts "Press ENTER to continue or any other key to abort"
          c = get_char
          #p c
          abort unless c == "\r"
        end

      end
    end

    class System
      class << self

        PWD = Dir.pwd

        def current_dir
          PWD
        end

        def to_exec(args)
          args = Shellwords.shellwords(args) if args.respond_to? :to_str
          Array(executable) + Array(args)
        end

        def command_to_string(cmd)
          full_cmd = to_exec(cmd)
          full_cmd.respond_to?(:shelljoin) ? full_cmd.shelljoin : full_cmd.join(' ')
        end

      end
    end

    class Context
      class << self

        # Cross-platform web browser command; respects the value set in $BROWSER.
        # 
        # Returns an array, e.g.: ['open']
        def browser_launcher
          browser = ENV['BROWSER'] || (
            osx? ? 'open' : windows? ? %w[cmd /c start] :
            %w[xdg-open cygstart x-www-browser firefox opera mozilla netscape].find { |comm| which comm }
          )

          abort "Please set $BROWSER to a web launcher to use this command." unless browser
          Array(browser)
        end

        def osx?
          require 'rbconfig'
          RbConfig::CONFIG['host_os'].to_s.include?('darwin')
        end

        def windows?
          require 'rbconfig'
          RbConfig::CONFIG['host_os'] =~ /msdos|mswin|djgpp|mingw|windows/
        end

        def unix?
          require 'rbconfig'
          RbConfig::CONFIG['host_os'] =~ /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i
        end

        # Cross-platform way of finding an executable in the $PATH.
        #
        #   which('ruby') #=> /usr/bin/ruby
        def which(cmd)
          exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
          ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
            exts.each { |ext|
              exe = "#{path}/#{cmd}#{ext}"
              return exe if File.executable? exe
            }
          end
          return nil
        end

        # Checks whether a command exists on this system in the $PATH.
        #
        # name - The String name of the command to check for.
        #
        # Returns a Boolean.
        def command?(name)
          !which(name).nil?
        end

        def tmp_dir
          ENV['TMPDIR'] || ENV['TEMP'] || '/tmp'
        end

        def terminal_width
          if unix?
            width = %x{stty size 2>#{NULL}}.split[1].to_i
            width = %x{tput cols 2>#{NULL}}.to_i if width.zero?
          else
            width = 0
          end
          width < 10 ? 78 : width
        end

      end
    end
  end
end