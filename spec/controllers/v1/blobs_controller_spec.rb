require 'rails_helper'

RSpec.describe V1::BlobsController, type: :controller do
  let(:valid_token) { ENV['AUTH_TOKEN'] }
  let(:storage_adapter) { instance_double("StorageAdapters::BaseAdapter") }
  let(:blob_id) { 'test_blob_id' }

  # Read the full data URI
  let(:blob_data) do
    File.read(Rails.root.join('spec', 'fixtures', 'base64_data_with_uri.txt')).strip
  end

  # Read the Base64 portion
  let(:encoded_data) do
    File.read(Rails.root.join('spec', 'fixtures', 'base64_data.txt')).strip
  end

  let(:decoded_data) { Base64.decode64(encoded_data) }

  before do
    allow(StorageAdapters::LocalStorage).to receive(:new).and_return(storage_adapter)
    allow(storage_adapter).to receive(:extract_base64_data).with(blob_data).and_return(encoded_data)
    allow(Base64).to receive(:decode64).with(encoded_data).and_return(decoded_data)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new blob and stores it successfully' do
        allow(storage_adapter).to receive(:store).with(blob_id, encoded_data).and_return(true)
        allow(Blob).to receive(:create!).with(id: blob_id, size: decoded_data.bytesize)

        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { id: blob_id, data: blob_data }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq({ "message" => "Blob stored successfully" })
      end
    end

    context 'with missing id' do
      it 'returns an error' do
        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { data: blob_data }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Invalid data: ID is required" })
      end
    end

    context 'with missing data' do
      it 'returns an error' do
        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { id: blob_id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Invalid data: Data is required" })
      end
    end

    context 'with storage failure' do
      it 'returns an error when storage fails' do
        allow(storage_adapter).to receive(:store).with(blob_id, encoded_data).and_return(false)

        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { id: blob_id, data: blob_data }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Failed to store blob" })
      end
    end

    context 'when a database error occurs' do
      it 'returns an error' do
        allow(storage_adapter).to receive(:store).with(blob_id, encoded_data).and_return(true)
        allow(Blob).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Blob.new))

        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { id: blob_id, data: blob_data }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Database error: Validation failed: " })
      end
    end
  end

  describe 'GET #show' do
    context 'when blob exists' do
      let!(:blob) { Blob.create!(id: blob_id, size: decoded_data.bytesize) }

      it 'retrieves the blob successfully' do
        allow(storage_adapter).to receive(:retrieve).with(blob.id).and_return(encoded_data)

        request.headers['Authorization'] = "Bearer #{valid_token}"
        get :show, params: { id: blob_id }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include("id" => blob.id, "data" => encoded_data, "size" => blob.size)
      end
    end

    context 'when blob does not exist' do
      it 'returns an error' do
        request.headers['Authorization'] = "Bearer #{valid_token}"
        get :show, params: { id: 'non_existing_id' }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "error" => "Blob not found" })
      end
    end
  end
end
