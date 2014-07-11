def reload_libs
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'tdameritrade_data_interface.rb')
  $stf = TDAmeritradeDataInterface  # I've created the $stf variable as an alias to make it easier to access TDAmeritradeDataInterface methods on the command line
end

reload_libs