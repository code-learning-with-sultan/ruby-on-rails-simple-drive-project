module StorageAdapters
  class DatabaseStorage < BaseAdapter
    def store(id, decoded_data)
      document = Document.new(id: id, file_data: decoded_data)
      raise document.errors.full_messages.join(", "), :unprocessable_entity unless document.save

      true # Return true if the operation succeeded
    end

    def retrieve(id)
      # retrieve blob data from Document record
      document = Document.find_by(id: id)
      raise "Document with ID #{id} not found", :not_found if document.nil?

      # Retrieve the binary data from the 'file_data' column
      decoded_data = document.file_data
      raise "Data with ID #{id} not found", :not_found if decoded_data.nil? || decoded_data.empty?

      begin
        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(decoded_data)

        # return the encoded blob
        encoded_data
      rescue StandardError => e
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      end
    end
  end
end
