class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents, id: false do |t|    # Disable the default auto-incrementing 'id'
      t.string :id, primary_key: true            # Add the manual primary key 'id'
      t.binary :file_data                        # For storing BLOB data
    end
  end
end
