module Brut
  module CLI
    module ExecutionResults
      class Result
        attr_reader :message
        def initialize(exit_status:,message:nil)
          @exit_status = exit_status
          @message = message
        end

        # Returns true if execution internal to the command should stop
        def stop?     = @exit_status != 0
        # Returns true if the execution of the command succeeded or didn't error
        def ok?       = @exit_status == 0
        # Returns the exit status to use for the CLI
        def to_i      = @exit_status
      end

      # Stop execution, even though nothing is wrong
      class Stop < Result
        def initialize
          super(exit_status: 0)
        end
        def stop? = true
      end

      # Continue execution
      class Continue < Result
        def initialize
          super(exit_status: 0)
        end
      end

      # Abort execution immediately
      class Abort < Result
        def initialize(exit_status:1,message:nil)
          if exit_status == 0
            raise ArgumentError,"Do not use Abort for a zero exit status"
          end
          super(exit_status:,message:)
        end
      end
      def stop_execution = Stop.new
      def continue_execution = Continue.new
      def abort_execution(message,exit_status:1) = Abort.new(message:,exit_status:)
      def as_execution_result(exit_status_or_execution_result)
        if exit_status_or_execution_result.kind_of?(Numeric) || exit_status_or_execution_result.nil?
          Result.new(exit_status: exit_status_or_execution_result.to_i)
        elsif exit_status_or_execution_result == true
          Result.new(exit_status: 0)
        elsif exit_status_or_execution_result == false
          Abort.new
        elsif exit_status_or_execution_result.kind_of?(Result)
          exit_status_or_execution_result
        else
          raise ArgumentError,"Your method returned a #{exit_status_or_execution_result.class} when it should return an exit status or one of the methods from ExecutionResults"
        end
      end
    end
  end
end
