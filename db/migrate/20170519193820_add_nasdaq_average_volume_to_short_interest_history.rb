class AddNasdaqAverageVolumeToShortInterestHistory < ActiveRecord::Migration
  def change
    add_column :short_interest_histories, :source, :string
    add_column :short_interest_histories, :average_volume, :float
  end
end
