module StorageAdapters
    class BaseAdapter
      def initialize; end

      def extract_base64_data(input)
        # Regex to match data URIs and extract Base64 portion
        data_uri_regex = /^data:(.*?);base64,(.*)$/

        if input.match?(data_uri_regex)
          # If it's a data URI, capture the Base64 part
          match = input.match(data_uri_regex)
          base64_data = match[2] # Return the Base64 part
        else
          # If it's just a Base64 string, return it directly
          base64_data = input
        end

        # Validate if the extracted string is a valid Base64 format
        valid_base64?(base64_data) ? base64_data : nil
      end

      def valid_base64?(data)
        # Check if the string is valid Base64
        data.is_a?(String) && data.match?(/\A[+\/0-9A-Za-z]{1,}={0,2}\z/)
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
