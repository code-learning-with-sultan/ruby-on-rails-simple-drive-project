class CreateBlobs < ActiveRecord::Migration[7.2]
  def change
    create_table :blobs, id: false do |t|
      t.string :id, primary_key: true
      t.integer :size

      t.timestamps
    end
  end
end
