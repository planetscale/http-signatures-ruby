module HttpSignatures
  class SigningString

    REQUEST_TARGET = "(request-target)"

    def initialize(header_list:, message:)
      @header_list = header_list
      @message = message
    end

    def to_str
      @header_list.to_a.map do |header|
        "%s: %s" % [header, header_value(header)]
      end.join("\n")
    end

    def header_value(header)
      return request_target if header == REQUEST_TARGET

      if @message.respond_to?(:headers)
        @message.headers.fetch(header) { raise HeaderNotInMessage, header }
      else
        @message.fetch(header) { raise HeaderNotInMessage, header }
      end
    end

    def request_target
      "%s %s" % [@message.method.downcase, @message.try(:original_fullpath) || @message.path]
    end
  end

  class HeaderNotInMessage < StandardError
    def initialize(name)
      super("Header '#{name}' not in message")
    end
  end

end
