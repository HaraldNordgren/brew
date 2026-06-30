# typed: true
# frozen_string_literal: true

require "cmd/unassume"
require "cmd/shared_examples/args_parse"

RSpec.describe Homebrew::Cmd::Unassume do
  it_behaves_like "parseable arguments"

  it "stops assuming a formula is installed", :integration_test do
    AssumedInstalled.add("testball")

    expect { brew "unassume", "testball" }.to be_a_success
  end

  it "warns when the formula is not assumed installed" do
    expect { described_class.new(["testball"]).run }
      .to output(/testball not assumed installed/).to_stderr
  end
end
