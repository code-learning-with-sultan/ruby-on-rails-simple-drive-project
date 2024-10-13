module StorageAdapters
  class DatabaseStorage < BaseAdapter
    def store(id, decoded_data)
      begin
        # TODO
        # Blob.create(id: id, size: Base64.decode64(data).bytesize, created_at: Time.current)
        true # Return true if the operation succeeded
      rescue StandardError => e
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      rescue => e # Catch-all for any other errors
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      begin
        # TODO
        decoded_data = ""

        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(decoded_data)

        # return the encoded blob
        encoded_data
      rescue StandardError => e
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      rescue => e # Catch-all for any other errors
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      end
    end
  end
end
