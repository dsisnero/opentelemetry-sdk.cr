require "./provider"
require "./meter"

module OpenTelemetry
  # A MeterProvider encapsulates a set of meter configuration, and provides an interface for creating Meter instances.
  class MeterProvider < Provider
    def meter(
      service_name : String? = nil,
      service_version : String? = nil,
      schema_url : String? = nil,
      exporter : Exporter? = nil,
      interval : Instrument::Number? = nil,
    )
      Meter.new(
        service_name || self.service_name,
        service_version || self.service_version,
        schema_url || self.schema_url,
        exporter || self.exporter,
        interval,
        self)
    end

    def meter(&)
      new_meter = meter()
      yield new_meter

      new_meter
    end
  end
end
