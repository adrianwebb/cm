
require 'rspec'
require 'stringio'
require 'cm'

#*******************************************************************************

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.color          = true
  config.formatter      = 'documentation'
end