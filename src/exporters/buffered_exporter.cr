require "nbchannel"

module OpenTelemetry
  class Exporter
    # A BufferedExporter provides a channel that can receive data to export,
    # defines a `start` method that will spawn a fiber to consume data that
    # enters the channel, and a `handle` method that will handle each data
    # element as it is received.
    module BufferedExporter
      include UnbufferedExporter

      @buffer : NBChannel(Elements) = NBChannel(Elements).new
      property batch_threshold = 100
      property batch_latency = 5
      property batch_interval = 0.05

      def start
        spawn { loop_and_receive }
      end

      def loop_and_receive
        elements = [] of Elements
        elements_size = 0
        mark = Time.instant
        oldsize = 0
        last_inspect = Time.instant
        loop do
          # NBChannel#receive? is deliberately non-blocking. Drain the buffer, then
          # sleep for the configured interval so an empty buffer cannot monopolize
          # the scheduler.
          while elements_size < @batch_threshold && (buffered_element = @buffer.receive?)
            elements << buffered_element
            elements_size += buffered_element.size
          end

          if oldsize != elements.size || (Time.instant - last_inspect).seconds > 1
            oldsize = elements.size
            last_inspect = Time.instant
            {% if flag? :DEBUG %}
              puts "#{self.object_id} : #{elements.size} >= #{@batch_threshold} || #{(Time.instant - mark).seconds} >= #{@batch_latency}"
            {% end %}
          end
          # If the internal buffer has reached the processing threshold size, or
          # if it has been longer than the batch_latency in seconds, then handle
          # each of the elements.
          if elements.size >= @batch_threshold || (Time.instant - mark).seconds >= @batch_latency
            handle(elements)
            elements.clear
            elements_size = 0
            mark = Time.instant
          end

          break if reaped?
          sleep(@batch_interval.seconds)
        end
      end
    end
  end
end
