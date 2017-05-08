module Utilities
  module ConvertHashFloatsToStrings
    extend self

    def convert_hash_floats_to_strings(hash)
      hash.each_key { |key| hash[key] = hash[key].to_s if hash[key].is_a? Float }
      hash
    end
  end
end