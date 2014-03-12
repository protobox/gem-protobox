module Protobox
  module Errors

    class Error < RuntimeError; end
    class FatalError < Error; end

  end
end