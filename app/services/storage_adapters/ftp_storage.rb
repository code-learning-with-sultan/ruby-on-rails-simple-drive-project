require "net/ftp"

module StorageAdapters
  class FtpStorage < BaseAdapter
    def initialize(
      host = ENV["FTP_HOST"],
      port = ENV["FTP_PORT"],
      username = ENV["FTP_USERNAME"],
      password = ENV["FTP_PASSWORD"]
    )
      connect(host, port, username, password)
    end

    def store(id, decoded_data)
      begin
        # Create a temporary file to store the decoded data
        Tempfile.create([ "uploaded_file", ".bin" ]) do |file|
          file.binmode              # Set binary mode for the file
          file.write(decoded_data)  # Write the decoded data to the file
          file.rewind               # Rewind the file pointer to the beginning

          # Upload the file to the FTP server
          @ftp.putbinaryfile(file.path, id)  # Use the file path for uploading
        end

        true # Return true if the operation succeeded
      rescue Net::FTPPermError => e
        raise "Permission error while storing blob with ID #{id}: #{e.message}"
      rescue Net::FTPReplyError => e
        raise "FTP reply error while storing blob with ID #{id}: #{e.message}"
      rescue StandardError => e
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      begin
        # Retrieve the file's contents
        decoded_data = @ftp.getbinaryfile(id, nil)
        raise "Data with ID #{id} not found", :not_found if decoded_data.nil? || decoded_data.empty?

        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(decoded_data)

        # return the encoded blob
        encoded_data
      rescue Net::FTPPermError => e
        raise "Permission error while retrieving blob with ID #{id}: #{e.message}"
      rescue Net::FTPReplyError => e
        raise "FTP reply error while retrieving blob with ID #{id}: #{e.message}"
      rescue StandardError => e
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      end
    end

    def connect(host, port, username, password)
      @ftp = Net::FTP.new
      begin
        @ftp.connect(host, port)
        @ftp.login(username, password)
      rescue Net::FTPPermError => e
        raise "Permission error while connecting to FTP: #{e.message}"
      rescue StandardError => e
        raise "An error occurred while connecting to FTP: #{e.message}"
      end
    end
  end
end
