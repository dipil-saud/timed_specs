$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pry'
require 'timed_specs'

# To properly reset the value of constants
# Extracted from: http://digitaldumptruck.jotabout.com/?p=551
def with_constants(constants)
  saved_constants = {}

  begin
    constants.each do |constant, val|
      saved_constants[constant] = TimedSpecs.const_get( constant )
      without_warnings { TimedSpecs.const_set(constant, val) }
    end
    yield
  ensure
    saved_constants.each do |constant, val|
      without_warnings { TimedSpecs.const_set(constant, val) }
    end
  end
end

# Assigning a value to a constant generates a warning which is supressed by this method
def without_warnings
  original_verbosity = $VERBOSE
  begin
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = original_verbosity
  end
end