class AddScreenshotFilenameToVIXFuturesHistory < ActiveRecord::Migration
  def change
    add_column :vix_futures_histories, :screenshot_filename, :string
  end
end
