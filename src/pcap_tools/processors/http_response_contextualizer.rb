class HttpResponseContextualizer
  def initialize
    @messages_in_time = {}
  end

  def process_stream stream
    stream.each do |index, req, resp|
      resp['request_path'] = req.path
    end

    stream
  end

  def finalize
  end

end