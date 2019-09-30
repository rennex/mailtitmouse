
require "warning"

# suppress this warning from tests
Warning.ignore(:ambiguous_slash, __dir__)

# suppress warnings from dependencies
Gem.path.each do |path|
  Warning.ignore(//, path)
end

