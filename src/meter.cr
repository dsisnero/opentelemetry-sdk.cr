require "./meter/exceptions"
require "./instrument"

module OpenTelemetry
  # Creates synchronous metric instruments and retains their provider configuration.
  class Meter
    getter name : String
    getter version : String
    getter schema_url : String
    getter exporter : Exporter?
    getter interval : Float64?
    getter provider : MeterProvider?

    def initialize(
      @name : String = "",
      @version : String = "",
      @schema_url : String = "",
      @exporter : Exporter? = nil,
      interval : Instrument::Number? = nil,
      @provider : MeterProvider? = nil,
    )
      @interval = interval.try(&.to_f64)
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
