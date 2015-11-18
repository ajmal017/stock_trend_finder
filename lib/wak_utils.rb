module WAKUtils
  def self.reload(require_regex)
    $".grep(/#{require_regex}/).each {|e| $".delete(e) && require(e) }
  end
end