require "./meter/exceptions"
require "./instrument"

module OpenTelemetry
  # Creates synchronous metric instruments. Exporter configuration and lifecycle
  # stay with the application or a future metric provider.
  class Meter
    getter name : String
    getter version : String
    getter schema_url : String

    def initialize(@name = "", @version = "", @schema_url = "")
    end

    def create_counter(name : String, unit : String = "", description : String = "") : Instrument::Counter
      Instrument::Counter.new(name, unit, description)
    end

    def create_histogram(name : String, unit : String = "", description : String = "") : Instrument::Histogram
      Instrument::Histogram.new(name, unit, description)
    end

    def create_up_down_counter(name : String, unit : String = "", description : String = "") : Instrument::UpDownCounter
      Instrument::UpDownCounter.new(name, unit, description)
    end
  end
end
