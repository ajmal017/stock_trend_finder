module Twitter
  class ConvertMessage
    include Verbalize::Action

    SUBSTITUTIONS=[
      ['#ub', 'upside break'],
      ['#ub', '52-wk upside break'],
      ['#ub-ath', 'all time high break'],
      ['#tookprofits', 'took profits'],
      ['#added', 'added']
    ]

    input :message

    def call
      "$".concat(message_with_substitutions)
    end

    private

    def message_with_substitutions
      SUBSTITUTIONS.reduce(message) do |s, (original_text,new_text)|
        s.gsub(original_text, new_text)
      end
    end
  end
end