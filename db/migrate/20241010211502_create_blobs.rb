class CreateBlobs < ActiveRecord::Migration[7.2]
  def change
    create_table :blobs do |t|
      t.string :id
      t.text :data
      t.integer :size
      t.string :storage_backend
      t.datetime :created_at

      t.timestamps
    end
  end
end
