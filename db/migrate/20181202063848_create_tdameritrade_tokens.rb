class CreateTDAmeritradeTokens < ActiveRecord::Migration
  def change
    create_table :tdameritrade_tokens do |t|
      t.string :refresh_token
      t.datetime :refresh_token_expires_at

      t.timestamps null: false
    end
  end
end
