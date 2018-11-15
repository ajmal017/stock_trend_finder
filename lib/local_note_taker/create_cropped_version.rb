module LocalNoteTaker
  class CreateCroppedVersion
    include Verbalize::Action

    input :input_file, :output_file

    def call
      `#{command}`
    end

    private

    def command
      "convert #{input_file} -crop '1675x1013+235+65' #{output_file}"
    end

  end
end