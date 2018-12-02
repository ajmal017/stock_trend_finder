class CreateTdAmeritradeTokens < ActiveRecord::Migration
  def change
    create_table :td_ameritrade_tokens do |t|
      t.string :refresh_token

      t.timestamps null: false
    end
  end
end
