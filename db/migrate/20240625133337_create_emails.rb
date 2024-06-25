class CreateEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :emails do |t|
      t.string :google_email_id

      t.timestamps
    end
  end
end
