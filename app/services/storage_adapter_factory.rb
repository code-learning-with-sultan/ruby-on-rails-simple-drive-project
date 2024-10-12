class StorageAdapterFactory
  def self.build(storage_backend)
    case storage_backend
    when "s3" then StorageAdapters::S3Storage.new
    when "db" then StorageAdapters::DatabaseStorage.new
    when "local" then StorageAdapters::LocalStorage.new
    when "ftp" then StorageAdapters::FtpStorage.new
    else nil
    end
  end
end
