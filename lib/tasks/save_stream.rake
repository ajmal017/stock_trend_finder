namespace :stock_trend_finder do

  desc "Saves a TD Ameritrade Level 1 stream to file for later backtesting"
  task :save_stream => :environment do
    client = TDAmeritradeApi::Client.new
    client.login
    streamer = client.create_streamer

    i = 0
    request_fields = [:volume, :last, :symbol, :quotetime, :tradetime]
    symbols = load_watchlist

    while true

      begin
        streamer.output_file = create_file_name
        streamer.run(symbols: symbols, request_fields: request_fields) do |data|
          data.convert_time_columns
          case data.stream_data_type
            when :heartbeat
              puts "Heartbeat: #{data.timestamp}"
            when :snapshot
              if data.service_id == "100"
                puts "Snapshot SID-#{data.service_id}: #{data.columns[:description]}"
              else
                puts "Snapshot: #{data}"
              end
            when :stream_data
              puts "#{i} Stream: #{data.columns}"
              i += 1
            else
              puts "Unknown type of data: #{data}"
          end
        end
      rescue Exception => e
        # This idiom of a rescue block you can use to reset the connection if it drops,
        # which can happen easily during a fast market.
        if e.class == Errno::ECONNRESET
          puts "Connection reset, reconnecting..."
        else
          raise e
        end
      end

    end

  end

  desc "Reads a TD Ameritrade Level 1 stream from file and outputs it to screen"
  task :read_stream, [:filename] do |t, args|
    i = 0
    streamer = TDAmeritradeApi::Streamer::Streamer.new(read_from_file: args[:filename])
    streamer.run do |data|
      data.convert_time_columns
      case data.stream_data_type
        when :heartbeat
          puts "Heartbeat: #{data.timestamp}"
        when :snapshot
          if data.service_id == "100"
            puts "Snapshot SID-#{data.service_id}: #{data.columns[:description]}"
          else
            puts "Snapshot: #{data}"
          end
        when :stream_data
          cols = data.columns.each { |k,v| "#{k}: #{v}, "}
          puts "#{i} Stream: #{cols}"
          i += 1
        else
          puts "Unknown type of data: #{data}"
      end
      streamer.quit if i == 3149
    end

  end


  private
  def create_file_name(i=0)
    fn = 1
    fn += 1 while File.exists? File.join(Dir.pwd, 'data_stream_archive', "stream_archive_#{Date.today.strftime('%Y%m%d')}-0#{fn}.binary")
    File.join(Dir.pwd, 'data_stream_archive', "stream_archive_#{Date.today.strftime('%Y%m%d')}-0#{fn}.binary")
  end

  def load_watchlist
    wl_file = File.join(Dir.pwd, 'data_stream_archive', 'watchlist.txt')
    f = File.open(wl_file, 'r')
    list = f.read().split("\n")
    f.close
    list
  end
end