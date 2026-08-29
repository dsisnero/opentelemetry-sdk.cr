require "../instrument"

module OpenTelemetry
  class Instrument
    class Histogram < Instrument
      def initialize(name, unit = "", description = "")
        super(name, "histogram", unit, description)
      end

      def record(value : Number, attributes : Hash(String, ValueTypes)? = nil) : Nil
        observe(value, attributes)
      end
    end
  end
end
