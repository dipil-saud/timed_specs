require 'spec_helper'

describe TimedSpecs do

  let(:output) { StringIO.new }
  let(:formatter) { TimedSpecs.new(output) }
  let(:example_group){ RSpec::Core::ExampleGroup.describe("dummy example group") }

  context "when initialized" do
    describe "@examples_with_execution_time" do
      it "should be initialized" do
        formatter.instance_variables.should include(:@examples_with_execution_time)
      end
      it "should be an empty array" do
        formatter.instance_variable_get("@examples_with_execution_time").should eq([])
      end
    end
  end

  describe "#start" do
    context "output" do
      before do
        formatter.start(0)
      end
      specify{ formatter.output.string.should include("Time Specs Enabled") }
    end
  end

  describe "#example_group_started" do
    before do
      @current_time = Time.now + 50
      Time.stub(:now).and_return(@current_time)
      formatter.example_group_started(example_group)
    end

    it "should initialize @group_time" do
      formatter.instance_variables.should include(:@group_time)
    end

    it "should set @group_time to the current time" do
      formatter.instance_variable_get("@group_time").should eq(@current_time)
    end

  end

  describe "#example_group_finished" do
    context "when @group_time is set" do
      before do
        @time1 = Time.now
        @time2 = Time.now + 10
        Time.stub(:now).and_return(@time2)
        formatter.stub(:current_indentation).and_return("###")
        formatter.instance_variable_set("@group_time", @time1)
        formatter.example_group_finished(example_group)
      end

      it "should reset @group_time" do
        formatter.instance_variable_get("@group_time").should be_nil
      end

      context "output" do
        subject{ formatter.output.string }
        it "should include the group time" do
          subject.should include((@time2 - @time1).round(3).to_s)
        end

        it "should include the current indentation" do
          subject.should include("###")
        end
      end
    end

    context "when @group_time is not set" do
      specify{ expect{formatter.example_group_finished(example_group)}.to_not raise_error }
      context "output" do
        before do
          formatter.example_group_finished(example_group)
        end
        subject{ formatter.output.string }
        it{ should include("\n") }
      end
    end
  end

  describe "#example_passed" do
    let(:example){
      double(
        "dummy example",
        :description => "my dummy example",
        :metadata => {
          :execution_result => {:status => 'passed', :exception => Exception.new , :run_time => 1.1234}
        },
        :location => "location_to_the_example"
      )
    }

    before do
      formatter.stub(:format_caller).with("location_to_the_example").and_return("formatted_location_to_the_example")
      formatter.example_passed(example)
    end

    it "should store the example in @examples_with_execution_time" do
      formatter.instance_variable_get("@examples_with_execution_time").length.should eq(1)
    end

    context "the stored example" do
      subject{ formatter.instance_variable_get("@examples_with_execution_time").first }

      it{ should be_an(Array) }

      it "should contain the description" do
        subject[0].should eq("my dummy example")
      end

      it "should contain the execution time" do
        subject[1].should eq(1.1234)
      end

      it "should contain the formatted location" do
        subject[2].should eq("formatted_location_to_the_example")
      end
    end

    context "output" do
      subject{ formatter.output.string }

      it{ should include(formatter.send(:cyan," : 1.123s")) }
    end
  end

  describe "#start_dump" do
    context "when there are no examples" do
      it "should not attempt to display the slowest examples" do
        formatter.should_receive(:output_slowest_examples).exactly(0).times
        formatter.start_dump
      end
    end
    context "when there are some examples" do
      it "should display the slowest examples" do
        formatter.instance_variable_set("@examples_with_execution_time", [1])
        formatter.should_receive(:output_slowest_examples).once.and_return(true)
        formatter.start_dump
      end
    end
  end

  describe "#output_slowest_examples" do
    let(:examples_with_execution_time){
      5.times.map{|x| ["example#{x}", rand(1000)/rand(1000).to_f, "location_to_example#{x}"] }
    }
    before do
      formatter.instance_variable_set("@examples_with_execution_time", examples_with_execution_time)
    end
    context "output" do
      it "should contain the slowest examples heading" do
        formatter.send("output_slowest_examples")
        formatter.output.string.should include("Slowest examples:")
      end
    end
    context "when the SLOWEST_EXAMPLES_COUNT is greater than the examples count" do
      it "should show the times for all the examples" do
        formatter.should_receive(:output_slow_example).exactly(5).times.and_return(true)
        formatter.send("output_slowest_examples")
      end
    end

    context "when the SLOWEST_EXAMPLES_COUNT is less than the examples count" do
      it "should only show the SLOWEST_EXAMPLES_COUNT number of examples" do
        formatter.should_receive(:output_slow_example).exactly(2).times.and_return(true)
        with_constants :SLOWEST_EXAMPLES_COUNT => 2 do
          formatter.send("output_slowest_examples")
        end
      end
    end
  end

  describe "#output_slow_example" do
    let(:slow_example){ ["example1", 1.23456, "location_to_example1"] }
    before do
      formatter.send("output_slow_example", slow_example)
    end
    context "output" do
      subject{ formatter.output.string }
      
      it{ should include("example1"), "should include the example description" }
      it{ should include(formatter.send(:bold, "1.2346")), "should include the example time" }
      it{ should include(formatter.send(:cyan, "# location_to_example1")), "should include the example location" }
    end
  end
  
  describe "#sort_by_run_time" do
    it "should sort the items in descending order of the second element in the array" do
      examples = 5.times.map{ [nil, rand(100), nil] }
      sorted_examples = formatter.send("sort_by_run_time", examples)

      sorted_examples[0..-2].each_index do |index|
        sorted_examples[index][1].should be > sorted_examples[index + 1][1]
      end
    end
  end
end