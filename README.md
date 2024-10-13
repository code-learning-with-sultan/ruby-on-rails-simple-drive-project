# Blob Storage API

This is a Ruby on Rails API for storing and retrieving blobs using various storage backends. The application supports local storage, FTP, Database, and S3 as storage options. It includes authentication via Bearer tokens and provides detailed error handling.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Running the Application](#running-the-application)
- [Testing the Application](#testing-the-application)
- [API Endpoints](#api-endpoints)

## Requirements

- Ruby (version 2.7 or higher)
- Rails (version 6.0 or higher)
- PostgreSQL (for database)
- Bundler (to manage gems)

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/code-learning-with-sultan/ruby-on-rails-simple-drive-project.git
   cd ruby-on-rails-simple-drive-project
   ```

2. **Install Dependencies**

   Make sure you have [Bundler](https://bundler.io/) installed, then run:

   ```bash
   bundle install
   ```

3. **Set Up Environment Variables**

   Copy the `.env.example` file to `.env` file in the root of your project and populate it with the necessary environment variables.

4. **Storage Backends Setup**:

   Update the `STORAGE_BACKEND` value in the `.env` file to change the storage backend

   ```dotenv
    STORAGE_BACKEND="local" # local, ftp, s3, db
   ```

5. **Set Up the Database**

   Make sure PostgreSQL is running and create the database by running:

   ```bash
   rails db:create
   rails db:migrate
   ```

## Running the Application

1. **Start the Rails Server**

   Run the following command to start the server:

   ```bash
   rails server
   ```

   The application will be accessible at `http://localhost:3000`.

## Testing the Application

Ensure you have RSpec installed, then run:

```bash
bundle exec rspec
```

## API Endpoints

### Blobs

- **POST /v1/blobs**

  - Create a new blob. Requires authorization.
  - **Request Body:**
    ```json
    {
      "id": "unique_blob_id",
      "data": "base64_encoded_data"
    }
    ```
  - **Response:**
    - 201 Created: Blob stored successfully.
    - 4XX, 5XX: Error details if the request fails.

- **GET /v1/blobs/:id**
  - Retrieve a blob by its ID. Requires authorization.
  - **Response:**
    - 200 OK: Blob details if found.
    ```json
    {
      "id": "any_valid_string_or_identifier",
      "data": "SGVsbG8gU2ltcGxlIFN0b3JhZ2UgV29ybGQh",
      "size": "27",
      "created_at": "2023-01-22T21:37:55Z"
    }
    ```
    - 4XX, 5XX: Error details if the request fails.
