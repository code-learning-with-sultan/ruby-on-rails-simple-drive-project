module StorageAdapters
  class LocalStorage < BaseAdapter
    def initialize(storage_path = ENV.fetch("LOCAL_STORAGE_PATH"))
      @storage_path = storage_path

      # Validate that the storage path exists
      unless Dir.exist?(@storage_path)
        raise ArgumentError, "Invalid storage path: #{@storage_path}. It must exist."
      end

      # Validate that the storage path is writable
      unless File.writable?(@storage_path)
        raise ArgumentError, "Invalid storage path: #{@storage_path}. It must be writable."
      end
    end

    def store(id, data)
      # Generates the file path for the blob based on its ID.
      filepath = File.join(@storage_path, id)

      begin
        # Decode the Base64 data
        decoded_data = Base64.decode64(data)

        # Write the decoded data to a file
        File.open(filepath, "wb") do |file|
          file.write(decoded_data)
        end

        true # Return true if the operation succeeded
      rescue ArgumentError => e
        raise ArgumentError, "Base64 decoding error for blob with ID #{id}: #{e.message}"
      rescue Errno::EACCES
        raise "Permission denied while writing to #{filepath}"
      rescue Errno::ENOENT
        raise "File not found error occurred while writing to #{filepath}"
      rescue StandardError => e
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      # Generates the file path for the blob based on its ID.
      filepath = File.join(@storage_path, id)

      # Check if the file exists before attempting to read it
      unless File.exist?(filepath)
        raise ActiveRecord::RecordNotFound, "Blob with ID #{id} not found at #{filepath}"
      end

      begin
        # Read the file's contents
        decoded_data = File.read(filepath)

        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(decoded_data)

        # return the encoded blob
        encoded_data
      rescue Errno::EACCES
        raise "Permission denied while reading from #{filepath}"
      rescue StandardError => e
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      end
    end
  end
end
