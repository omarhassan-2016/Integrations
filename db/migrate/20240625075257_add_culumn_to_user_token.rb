class AddCulumnToUserToken < ActiveRecord::Migration[7.0]
  def change
    add_column :user_tokens, :google_credentials, :jsonb
  end
end
