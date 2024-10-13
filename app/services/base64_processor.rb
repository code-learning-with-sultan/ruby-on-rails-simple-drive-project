class Base64Processor
  DATA_URI_REGEX = /\Adata:(?<media_type>.*?);base64,(?<base64_data>.*)\z/.freeze # /^data:(.*?);base64,(.*)$/
  BASE64_REGEX = /\A[+\/0-9A-Za-z]{1,}={0,2}\z/.freeze

  class << self
    # Decode the provided Base64 string into binary data.
    def decode_base64_data(data)
      return if data.blank?

      extracted_data = extract_base64_data(data)
      return if extracted_data.blank?

      decoded_data = Base64.decode64(extracted_data)
      decoded_data.presence # Rails' `presence` returns nil if the string is blank
    end

    # Extract Base64 data from a given input, handling both plain Base64 strings and data URIs.
    def extract_base64_data(input)
      return unless input.is_a?(String)

      if (match = input.match(DATA_URI_REGEX))
        base64_data = match[:base64_data]
      else
        base64_data = input
      end

      valid_base64?(base64_data) ? base64_data : nil
    end

    # Validate if a string is a valid Base64 encoded format.
    def valid_base64?(data)
      data.is_a?(String) && data.match?(BASE64_REGEX)
    end
  end
end
