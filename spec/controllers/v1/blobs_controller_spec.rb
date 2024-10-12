require 'rails_helper'

RSpec.describe V1::BlobsController, type: :controller do
  let(:valid_token) { ENV['AUTH_TOKEN'] }
  let(:storage_adapter) { instance_double("StorageAdapter") }
  let(:blob_id) { 'test_blob_id' }
  let(:blob_data) {
    'data:@file/jpeg;base64,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'
  }
  let(:decoded_data) { Base64.decode64(blob_data.split(',')[1]) } # Decoding the Base64 data

  before do
    # Set up the storage adapter mock
    allow(StorageAdapters::LocalStorage).to receive(:new).and_return(storage_adapter)
    allow(storage_adapter).to receive(:get_decoded_data).with(blob_data).and_return(decoded_data)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new blob and stores it successfully' do
        allow(storage_adapter).to receive(:store).with(blob_id, blob_data).and_return(true)

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
        allow(storage_adapter).to receive(:store).with(blob_id, blob_data).and_return(false)

        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, params: { id: blob_id, data: blob_data }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "error" => "Failed to store blob" })
      end
    end
  end

  describe 'GET #show' do
    context 'when blob exists' do
      let!(:blob) { Blob.create!(id: blob_id, size: decoded_data.bytesize) }

      it 'retrieves the blob successfully' do
        allow(storage_adapter).to receive(:retrieve).with(blob.id).and_return(blob_data)

        request.headers['Authorization'] = "Bearer #{valid_token}"
        get :show, params: { id: blob_id }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include("id" => blob.id, "data" => blob_data, "size" => blob.size)
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
