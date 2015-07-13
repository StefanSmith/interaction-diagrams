class HttpResponseInteractionDiagramMapper

  def initialize(formatter, write_response_body)
    @formatter = formatter
    @write_response_body = write_response_body
  end

  def note_from(http_response)
    body_lines = []
    body_lines << "Location: #{http_response.location_header.scrub}" if http_response.location_header
    body_lines << "Set-Cookie: #{http_response.set_cookie_header.scrub}" if http_response.set_cookie_header

    if @write_response_body && http_response.body

      if http_response.content_type_header
        body_lines << ' \n'
        body_lines << http_response.content_type_header.scrub
      end

      body_lines << ' \n'
      body_lines << http_response.body.scrub
    end

    @formatter.multiline_text_from(body_lines).strip
  end

  def message_from(http_response)
    http_response.response_code
  end

end