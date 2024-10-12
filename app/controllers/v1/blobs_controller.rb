module V1
  class BlobsController < ApplicationController
    before_action :set_storage_adapter

    def create
      # Ensure required parameters are present and valid
      raise ArgumentError, "ID is required" if params[:id].blank?
      raise ArgumentError, "Data is required" if params[:data].blank?

      id = params[:id]
      data = @storage_adapter.extract_base64_data(params[:data])

      # Decode the Base64 data
      decoded_data = Base64.decode64(data)

      # Validate and create a new blob record in the database
      blob = Blob.new(id: id, size: decoded_data.bytesize)
      if blob.save
        # Attempt to store the blob using the storage adapter
        if @storage_adapter.store(id, data)
          render json: { message: "Blob stored successfully" }, status: :created
        else
          blob.destroy # Rollback blob creation if storage fails
          render json: { error: "Failed to store blob" }, status: :unprocessable_entity
        end
      else
        # Handle validation errors
        render json: { error: "Validation failed: #{blob.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
      end
    rescue ArgumentError => e
      render json: { error: "Invalid data: #{e.message}" }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Database error: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end

    def show
      # Ensure required parameters are present and valid
      raise ArgumentError, "ID is required" if params[:id].blank?

      # Attempt to find the corresponding blob in the database
      blob = Blob.find_by(id: params[:id])
      return render json: { error: "Blob not found" }, status: :not_found unless blob

      # Retrieve the encoded data from the storage adapter
      encoded_data = @storage_adapter.retrieve(blob.id)

      render json: { id: blob.id, data: encoded_data, size: blob.size, created_at: blob.created_at }
    rescue StandardError => e
      render json: { error: "An error occurred while retrieving the blob: #{e.message}" }, status: :internal_server_error
    end

    private

    # Sets the appropriate storage adapter based on the environment configuration.
    #
    # @raise [RuntimeError] If an invalid storage backend is specified.
    def set_storage_adapter
      @storage_adapter = case ENV["STORAGE_BACKEND"]
      when "s3" then StorageAdapters::S3Storage.new
      when "db" then StorageAdapters::DatabaseStorage.new
      when "local" then StorageAdapters::LocalStorage.new
      when "ftp" then StorageAdapters::FTPStorage.new
      else raise "Invalid storage backend"
      end
    end
  end
end
