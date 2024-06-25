class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :google_event_id

      t.timestamps
    end
  end
end
