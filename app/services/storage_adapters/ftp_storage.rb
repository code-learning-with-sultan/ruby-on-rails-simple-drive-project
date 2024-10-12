require "net/ftp"

module StorageAdapters
  class FTPStorage < BaseAdapter
    def initialize(
      host = ENV.fetch("FTP_HOST"),
      username = ENV.fetch("FTP_USERNAME"),
      password = ENV.fetch("FTP_PASSWORD")
    )
      @ftp = Net::FTP.new
      begin
        @ftp.connect(host)
        @ftp.login(username, password)
      rescue Net::FTPPermError => e
        raise "Permission error while connecting to FTP: #{e.message}"
      rescue StandardError => e
        raise "An error occurred while connecting to FTP: #{e.message}"
      end
    end

    def store(id, data)
      begin
        # Attempt to decode Base64 data
        decoded_data = get_decoded_data(data)

        # Upload the file to the FTP server
        @ftp.putbinaryfile(StringIO.new(decoded_data), id)

        true # Return true if the operation succeeded
      rescue ArgumentError => e
        raise ArgumentError, "Base64 decoding error for blob with ID #{id}: #{e.message}"
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
  end
end
