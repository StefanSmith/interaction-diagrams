require_relative 'processors/http_message_chronicler'
require_relative 'processors/http_request_decompressor'
require_relative 'processors/http_response_contextualizer'

  class TcpProcessor < PcapTools::TcpProcessor

    def finalize
      @streams.keys.each do |stream_index|
        current = {:index => stream_index, :data => @streams[stream_index][:data]}
        @stream_processors.each do |p|
          current = p.process_stream current
          break unless current
        end
        @streams.delete stream_index
      end

      super
    end

  end

class PcapToolsHttpMessageParser
  def parse_file(pcap_file_path)
    processor = TcpProcessor.new
    processor.add_stream_processor PcapTools::TcpStreamRebuilder.new
    processor.add_stream_processor PcapTools::HttpExtractor.new
    processor.add_stream_processor HttpRequestDecompressor.new
    processor.add_stream_processor HttpResponseContextualizer.new
    http_events_capture_processor = HttpMessageChronicler.new
    processor.add_stream_processor http_events_capture_processor

    PcapTools::Loader::load_file(pcap_file_path, {:accepted_protocols => ['ipv6']}) do |index, packet|
      processor.inject index, packet
    end

    processor.finalize

    http_events_capture_processor.chronological_messages
  end
end