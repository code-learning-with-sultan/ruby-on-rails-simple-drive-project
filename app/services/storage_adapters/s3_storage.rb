require "openssl"
require "net/http"
require "uri"
require "time"
require "digest"

module StorageAdapters
  class S3Storage < BaseAdapter
    def initialize(
      access_key_id = ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"],
      region = ENV["AWS_REGION"],
      bucket = ENV["AWS_BUCKET"],
      service = ENV["AWS_SERVICE"] || "s3"
    )
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @bucket = bucket
      @service = service
    end

    def store(id, decoded_data)
      begin
        # Prepare HTTP request headers
        headers = aws4_headers(decoded_data, "PUT", id)
        headers["Content-Type"] = "text/plain"

        # HTTP request endpoint
        endpoint = "https://#{@bucket}.s3.#{@region}.amazonaws.com/#{id}"

        # Send the PUT request
        uri = URI.parse(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri, headers)
        request.body = decoded_data

        response = http.request(request)
        raise "Error uploading file: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        true # Return true if the operation succeeded
      rescue SocketError => e
        raise "Network error: #{e.message}. Please check your internet connection or the AWS endpoint."
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise "Timeout error: #{e.message}. The request took too long to respond."
      rescue StandardError => e
        raise "An error occurred while storing blob with ID #{id}: #{e.message}"
      end
    end

    def retrieve(id)
      begin
        # Prepare HTTP request headers
        headers = aws4_headers("", "GET", id)

        # HTTP request endpoint
        endpoint = "https://#{@bucket}.s3.#{@region}.amazonaws.com/#{id}"

        # Send the GET request
        uri = URI.parse(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri, headers)

        response = http.request(request)
        raise "Error retrieving file: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        # Retrieve the file's contents
        decoded_data = response.body
        raise "Data with ID #{id} not found", :not_found if decoded_data.nil? || decoded_data.empty?

        # Encode the response body in Base64
        encoded_data = Base64.strict_encode64(decoded_data)

        # return the encoded blob
        encoded_data
      rescue SocketError => e
        raise "Network error: #{e.message}. Please check your internet connection or the AWS endpoint."
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise "Timeout error: #{e.message}. The request took too long to respond."
      rescue StandardError => e
        raise "An error occurred while retrieving blob with ID #{id}: #{e.message}"
      end
    end

    private

    def aws4_headers(payload, method, id)
      t = Time.now.utc
      amz_date = t.strftime("%Y%m%dT%H%M%SZ")   # x-amz-date header format
      date_stamp = t.strftime("%Y%m%d")         # Date used in credential scope

      payload_hash = Digest::SHA256.hexdigest(payload)

      # Canonical request components
      method = "#{method}"
      canonical_uri = "/#{id}"
      canonical_querystring = ""
      canonical_headers = "host:#{@bucket}.s3.#{@region}.amazonaws.com\nx-amz-content-sha256:#{payload_hash}\nx-amz-date:#{amz_date}\n"
      signed_headers = "host;x-amz-content-sha256;x-amz-date"
      canonical_request = "#{method}\n#{canonical_uri}\n#{canonical_querystring}\n#{canonical_headers}\n#{signed_headers}\n#{payload_hash}"

      # String to sign
      algorithm = "AWS4-HMAC-SHA256"
      credential_scope = "#{date_stamp}/#{@region}/#{@service}/aws4_request"
      string_to_sign = "#{algorithm}\n#{amz_date}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"

      # Generate the signing key
      signing_key = get_signature_key(@secret_access_key, date_stamp, @region, @service)
      signature = OpenSSL::HMAC.hexdigest("sha256", signing_key, string_to_sign)

      # Authorization header
      authorization_header = "#{algorithm} Credential=#{@access_key_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

      {
        "x-amz-date" => amz_date,
        "x-amz-content-sha256" => payload_hash,
        "Authorization" => authorization_header
      }
    rescue StandardError => e
      raise "Error generating AWS4 headers: #{e.message}"
    end

    def get_signature_key(key, date_stamp, region_name, service_name)
      k_date = sign("AWS4" + key, date_stamp)
      k_region = sign(k_date, region_name)
      k_service = sign(k_region, service_name)
      k_signing = sign(k_service, "aws4_request")
      k_signing
    rescue StandardError => e
      raise "Error generating signature key: #{e.message}"
    end

    def sign(key, msg)
      OpenSSL::HMAC.digest("sha256", key, msg)
    rescue StandardError => e
      raise "Error signing message: #{e.message}"
    end
  end
end
