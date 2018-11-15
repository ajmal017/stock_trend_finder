class AddImageCroppedUrlToStocktwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :image_cropped_url, :string
  end
end
