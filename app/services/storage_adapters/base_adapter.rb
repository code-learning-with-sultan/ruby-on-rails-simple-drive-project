module StorageAdapters
    class BaseAdapter
      def initialize; end

      # Abstract method for storing data in the backend
      #
      # @param id [String] Unique identifier for the blob
      # @param decoded_data [String] The decoded data to store
      # @raise [NotImplementedError] to enforce implementation in subclasses
      def store(id, decoded_data)
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
