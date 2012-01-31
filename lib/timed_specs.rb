require 'rspec/core/formatters/documentation_formatter'


class TimedSpecs < RSpec::Core::Formatters::DocumentationFormatter
  SLOWEST_EXAMPLES_COUNT = (ENV['SLOWEST_EXAMPLES_COUNT'] || 20).to_i

  def initialize(*args)
    super
    @examples_with_execution_time = []
  end

  def start(*args)
    @output.puts "Time Specs Enabled"
    super
  end

  def example_group_started(*args)
    @group_time = Time.now
    super
  end

  def example_group_finished(*args)
    super
    if @group_time
      output.puts current_indentation + white("#{(Time.now - @group_time).round(3)}s")
      @group_time = nil
    else
      output.puts
    end
  end

  # Overridden method of the base documentation formatter
  # Is executed after each passed example
  def example_passed(example)
    super(example)
    @examples_with_execution_time << [
      example.description,
      example.metadata[:execution_result][:run_time], # this is the time taken to execute the example
      format_caller(example.location) # relative path to the example file
    ]
  end

  # Overridden method of the base documentation formatter
  # Used by DocumentationFormatter to display the example info after each passed example
  # super - displays the example description
  # Then display the execution time beside it
  def passed_output(example)
    super + cyan(" : #{example.metadata[:execution_result][:run_time].round(3)}s")
  end

  def start_dump
    output_slowest_examples unless @examples_with_execution_time.empty?
    super
  end

  private

  def output_slowest_examples
    output.puts bold("\n\nSlowest examples:\n")

    sort_by_run_time(@examples_with_execution_time)[0..SLOWEST_EXAMPLES_COUNT-1].each do |example|
      output_slow_example(example)
    end
  end

  def output_slow_example(example)
    output.puts "#{bold(example[1].round(4))} #{example[0]}"
    output.puts "    " + cyan("# #{example[2]}")
  end

  def sort_by_run_time(examples)
    # example[1] = example_run_time
    examples.sort{|x,y| y[1] <=> x[1] }
  end
end
