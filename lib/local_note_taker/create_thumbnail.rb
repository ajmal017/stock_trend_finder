module LocalNoteTaker
  class CreateThumbnail
    include Verbalize::Action

    input :input_file, :output_file

    def call
      `#{command}`
    end

    private

    def command
      "convert #{input_file} -resize 175x175 #{output_file}"
    end

  end
end