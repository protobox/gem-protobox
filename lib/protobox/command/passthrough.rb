module Protobox
  module Command
    class PassThrough
      def self.execute args
        #puts args.inspect

        vagrant = Protobox::Util::Platform.vagrant

        args.insert(0, vagrant)
        args.insert(1, 'protobox')

        system *args

        # Success, exit status 0
        0
      end
    end
  end
end