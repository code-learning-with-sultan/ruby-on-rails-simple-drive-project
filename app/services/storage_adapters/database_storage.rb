module StorageAdapters
  class DatabaseStorage < BaseAdapter
    def store(id, data)
      # Blob.create(id: id, size: Base64.decode64(data).bytesize, created_at: Time.current)
    end

    def retrieve(id)
      blob = Blob.find_by(id: id)
      return unless blob

      blob_data = "" # TODO

      { id: blob.id, data: blob_data, size: blob.size, created_at: blob.created_at }
    end
  end
end
