require 'net/http'
require 'socket'
require 'tempfile'

# Boots the app in a separate `rackup` process on a free local port so feature
# specs can send real HTTP requests (real Puma, real sockets). Uses the same
# Ruby and bundle as the spec run.
#
# 🤖 AI Usage Disclosure: Designed and implemented by Claude (Anthropic).
class RunningApp
  BOOT_TIMEOUT = 20 # seconds

  attr_reader :port, :log

  # @return [RunningApp] a started server
  # @raise [RuntimeError] if the server doesn't accept connections in time
  def self.start
    new.tap(&:start)
  end

  def start
    @port = free_port
    @log  = Tempfile.new('rackup-log')
    env   = { 'RACK_ENV' => 'production' }
    @pid  = Process.spawn(env, 'bundle', 'exec', 'rackup', '-o', '127.0.0.1', '-p', port.to_s,
                          chdir: ROOT, out: log.path, err: log.path)
    wait_until_listening
  end

  def stop
    return unless @pid

    Process.kill('TERM', @pid)
    Process.wait(@pid)
    @pid = nil
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  ensure
    log&.close!
  end

  # @param path [String]
  # @return [Net::HTTPResponse]
  def get(path)
    Net::HTTP.get_response(uri(path))
  end

  # @param path [String]
  # @param params [Hash] form fields
  # @return [Net::HTTPResponse]
  def post(path, params)
    Net::HTTP.post_form(uri(path), params)
  end

  # @return [String] everything the server has written so far
  def output
    File.read(log.path)
  end

  private

  def uri(path)
    URI("http://127.0.0.1:#{port}#{path}")
  end

  def free_port
    server = TCPServer.new('127.0.0.1', 0)
    server.addr[1]
  ensure
    server&.close
  end

  def wait_until_listening
    deadline = Time.now + BOOT_TIMEOUT
    until Time.now > deadline
      begin
        return TCPSocket.new('127.0.0.1', port).close
      rescue Errno::ECONNREFUSED
        raise "server exited during boot:\n#{output}" if Process.waitpid(@pid, Process::WNOHANG)

        sleep 0.1
      end
    end
    stop
    raise "server not listening after #{BOOT_TIMEOUT}s"
  end
end
