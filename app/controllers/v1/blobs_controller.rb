module V1
  class BlobsController < ApplicationController
    before_action :set_storage_adapter

    def create
      blob_params = params.permit(:id, :data)

      # Validate & Decode Base64 data
      decoded_data = Base64Processor.decode_base64_data(blob_params[:data])
      render_error("Invalid base64 format", :unprocessable_entity) and return if decoded_data.blank?

      # Validate & Create a new blob record
      blob = Blob.new(id: blob_params[:id], size: decoded_data.bytesize)
      render_error(blob.errors.full_messages.join(", "), :unprocessable_entity) and return unless blob.save

      # Store the blob in the specified storage
      begin
        @storage_adapter.store(blob.id, decoded_data)
        render json: { message: "Blob stored successfully" }, status: :created
      rescue StandardError => e
        blob.destroy # Rollback blob creation if storage fails
        render_error("Storage error: #{e.message}", :internal_server_error)
      end
    rescue ArgumentError => e
      render_error("Invalid data: #{e.message}", :unprocessable_entity)
    rescue ActiveRecord::RecordInvalid => e
      render_error("Database error: #{e.message}", :unprocessable_entity)
    rescue ActiveRecord::RecordNotUnique
      render_error("Blob with this ID already exists", :conflict)
    rescue StandardError => e
      render_error("An unexpected error occurred: #{e.message}", :internal_server_error)
    end

    def show
      # Find the blob by ID
      blob = Blob.find_by(id: params[:id])
      render_error("Blob not found", :not_found) and return unless blob

      begin
        encoded_data = @storage_adapter.retrieve(blob.id)
        render_error("Blob file not found", :not_found) and return unless encoded_data

        render json: {
          id: blob.id,
          data: encoded_data,
          size: blob.size,
          created_at: blob.created_at
        }
      rescue ActiveRecord::RecordNotFound => e
        render_error(e.message, :not_found)
      rescue StandardError => e
        render_error(e.message, :internal_server_error)
      end
    end

    private

    # Set the appropriate storage adapter
    def set_storage_adapter
      @storage_adapter = StorageAdapterFactory.build(ENV["STORAGE_BACKEND"])
      raise "Invalid storage backend", :internal_server_error unless @storage_adapter
    end

    # Render JSON error message
    def render_error(message, status)
      render json: { error: message }, status: status
    end
  end
end
