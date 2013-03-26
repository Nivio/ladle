require 'ladle'
require 'open3'

module Ladle
  ##
  # Implementations of platform-specific process handling behaviors for Ruby.
  class RubyProcess
    ##
    # Create a new process for the given command and its args.
    def initialize(*command_and_args)
      @command_and_args = command_and_args
    end

    ##
    # Start the process and return pipes to its standard streams.
    #
    # @return [[IO, IO, IO]] stdin, stdout, and stderr for the running process.
    def popen
      i, o, e, wait_thr = Open3.popen3(@command_and_args.join(' '))
      @pid = wait_thr.pid
      @wait_thread = wait_thr
      [i, o, e]
    end

    ##
    # Wait for the process to finish.
    #
    # @return [Fixnum] the return status of the process.
    def wait
      @wait_thread.value
    end

    ##
    # Send signal 15 to the process.
    #
    # @return [void]
    def stop_gracefully
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        signal = 9
      else
        signal = 15
      end

      begin
        Process.kill signal, pid
      rescue Errno::ESRCH
      end
    end

    ##
    # @return [Fixnum] the PID for the process
    def pid
      @pid
    end
  end
end
