##
# Define the application-specific error hierarchy here.
#
# All application errors must descend from ApplicationError.
# Further descendents of these errors may be defined locally within other files.
#
# For example:
#
#     # foo.rb
#     class Foo
#       class FooSpecificError < Exceptions::ApplicationError; end
#
#       def check_something
#         raise FooSpecificError unless some_condition
#       end
#     end

module Exceptions
  class ApplicationError < StandardError; end
  class NotImplementedError < ApplicationError; end
  class PaymentVerificationError < ApplicationError; end
end
