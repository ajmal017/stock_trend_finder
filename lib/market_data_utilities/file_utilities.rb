require 'open-uri'

module FileUtilities
  def download_file(url, local_path, print: true)
    puts "Downloading #{url} > #{local_path}" if print
    open(local_path, 'w') do |file|
      file << open(url).read
    end
  end

  def downloads_folder
    File.join(Dir.pwd, 'downloads')
  end
end