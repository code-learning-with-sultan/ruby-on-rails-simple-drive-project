module StorageAdapters
    class BaseAdapter
      def initialize; end

      def extract_base64_data(input)
        # Regex to match data URIs and extract Base64 portion
        data_uri_regex = /^data:(.*?);base64,(.*)$/

        if input.match?(data_uri_regex)
          # If it's a data URI, capture the Base64 part
          match = input.match(data_uri_regex)
          match[2] # Return the Base64 part
        else
          # If it's just a Base64 string, return it directly
          input
        end
      end

      # Decodes Base64 encoded data and validates its integrity
      #
      # @param data [String] Base64 encoded data
      # @return [String] Decoded data
      # @raise [ArgumentError] if data is not a String, nil, or empty, or if decoding fails
      def get_decoded_data(base64_data)
        # Validate that input is a String
        raise ArgumentError, "Data must be a String" unless base64_data.is_a?(String)
        raise ArgumentError, "Data cannot be nil or empty" if base64_data.nil? || base64_data.empty?

        begin
          # Decode the Base64 data
          decoded_data = Base64.decode64(base64_data)

          # Validate that the original data matches the re-encoded data
          unless Base64.strict_encode64(decoded_data) == base64_data
            raise ArgumentError, "Invalid Base64 data: data does not match after decoding."
          end

          # Return the successfully decoded data
          decoded_data
        rescue ArgumentError => e
          # Raise a more specific error message if decoding fails
          raise ArgumentError, "Base64 decoding error: #{e.message}"
        rescue StandardError => e
          # Catch any unexpected errors during the decoding process
          raise "An unexpected error occurred during Base64 decoding: #{e.message}"
        end
      end

      # Abstract method for storing data in the backend
      #
      # @param id [String] Unique identifier for the blob
      # @param data [String] The data to store
      # @raise [NotImplementedError] to enforce implementation in subclasses
      def store(id, data)
        raise NotImplementedError
      end

      # Abstract method for retrieving data from the backend
      #
      # @param id [String] Unique identifier for the blob
      # @raise [NotImplementedError] to enforce implementation in subclasses
      def retrieve(id)
        raise NotImplementedError
      end
    end
end
