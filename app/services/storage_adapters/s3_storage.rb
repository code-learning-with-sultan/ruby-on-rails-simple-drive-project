require "net/http"
require "uri"
require "base64"

module StorageAdapters
  class S3Storage < BaseAdapter
    def initialize(
      bucket_url = ENV["S3_BUCKET_URL"],
      access_key = ENV["S3_ACCESS_KEY"],
      secret_key = ENV["S3_SECRET_KEY"]
    )
      @bucket_url = bucket_url
      @access_key = access_key
      @secret_key = secret_key
    end

    def store(id, decoded_data)
      begin
        # Prepare the URI and HTTP request
        uri = URI("#{@bucket_url}/#{id}")
        request = Net::HTTP::Put.new(uri)
        request.body = decoded_data

        # Send the request
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

        # Check if the request was successful, otherwise raise an error
        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to store blob with ID #{id}: #{response.code} #{response.message}"
        end

        true # Return true if everything succeeded
      rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Network error while storing blob with ID #{id}: #{e.message}"
      rescue => e # Catch-all for any other errors
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      # Prepare the URI and HTTP request
      uri = URI("#{@bucket_url}/#{id}")

      begin
        # Send the request
        response = Net::HTTP.get_response(uri)

        # Check if the request was successful, otherwise raise an error
        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to retrieve blob with ID #{id}: #{response.code} #{response.message}"
        end

        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(response.body)

        # return the encoded blob
        encoded_data
      rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Network error while retrieve blob with ID #{id}: #{e.message}"
      rescue ArgumentError => e
        raise ArgumentError, e.message
      rescue StandardError => e
        raise "An error occurred while retrieve blob with ID #{id}: #{e.message}"
      rescue => e # Catch-all for any other errors
        raise "An error occurred while retrieve blob with ID #{id}: #{e.message}"
      end
    end
  end
end
