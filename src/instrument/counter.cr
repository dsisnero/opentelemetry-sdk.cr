require "../instrument"

module OpenTelemetry
  class Instrument
    class Counter < Instrument
      def initialize(name, unit = "", description = "")
        super(name, "counter", unit, description)
      end

      def add(value : Number, attributes : Hash(String, ValueTypes)? = nil, labels : Hash(String, String)? = nil) : Nil
        observe(value, attributes)
      end
    end
  end
end
