class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.bigint :twitter_message_id
      t.string :message
      t.string :local_image_url
      t.datetime :posted_at

      t.timestamps null: false
    end
  end
end
