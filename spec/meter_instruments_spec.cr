require "spec"
require "opentelemetry-api/interfaces"
require "../src/meter"

describe OpenTelemetry::Meter do
  it "creates the synchronous metric instruments required by metrics adapters" do
    meter = OpenTelemetry::Meter.new
    attributes = {} of String => OpenTelemetry::ValueTypes
    attributes["kind"] = "task"

    counter = meter.create_counter("events_total", description: "events")
    histogram = meter.create_histogram("duration_seconds", description: "duration")
    gauge = meter.create_up_down_counter("queue_depth", description: "depth")

    counter.should be_a(OpenTelemetry::Instrument::Counter)
    histogram.should be_a(OpenTelemetry::Instrument::Histogram)
    gauge.should be_a(OpenTelemetry::Instrument::UpDownCounter)

    counter.add(2, attributes)
    histogram.record(1.5, attributes)
    gauge.add(-1, attributes)

    counter.observations[0].value.should eq(2.0)
    histogram.observations[0].value.should eq(1.5)
    gauge.observations[0].value.should eq(-1.0)
    gauge.observations[0].attributes.should eq(attributes)
  end
end
