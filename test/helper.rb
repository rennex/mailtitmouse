require "minitest/autorun"

require "warning"
Gem.path.each do |path|
  Warning.ignore(//, path)
end
