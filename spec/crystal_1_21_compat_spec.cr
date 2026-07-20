require "./spec_helper"

describe "Crystal 1.21 compatibility" do
  it "constructs event, span, and trace objects through the public SDK surface" do
    checkout_config do
      event = OpenTelemetry::Event.new("event")
      event.parent_span.should be_nil

      span = OpenTelemetry::Span.new("span")
      span.events << event
      span.events.first.should eq(event)

      trace = OpenTelemetry::TraceProvider.new(
        service_name: "compat",
        exporter: OpenTelemetry::Exporter.new(:null)
      ).trace
      trace.in_span("request") { }
      trace.to_json.should contain("\"spans\"")
    end
  end
end
