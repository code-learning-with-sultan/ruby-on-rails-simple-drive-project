module StorageAdapters
  class DatabaseStorage < BaseAdapter
    def store(id, decoded_data)
      # Blob.create(id: id, size: Base64.decode64(data).bytesize, created_at: Time.current)
    end

    def retrieve(id)
      decoded_data = ""

      # Encode the response body in Base64
      encoded_data = Base64.strict_encode64(decoded_data)

      # return the encoded blob
      encoded_data
    end
  end
end
