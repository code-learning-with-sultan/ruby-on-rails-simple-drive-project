module StorageAdapters
  class DatabaseStorage < BaseAdapter
    def store(id, decoded_data)
      begin
        document = Document.new(id: id, file_data: decoded_data)
        raise document.errors.full_messages.join(", ") unless document.save

        true # Return true if the operation succeeded
      rescue StandardError => e
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      rescue => e # Catch-all for any other errors
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      begin
        # retrieve blob data from Document record
        document = Document.find_by(id: id)

        if document.nil?
          raise "Document with ID #{id} not found"
        end

        # Retrieve the binary data from the 'file_data' column
        decoded_data = document.file_data

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
