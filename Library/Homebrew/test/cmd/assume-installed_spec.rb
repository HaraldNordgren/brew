# typed: true
# frozen_string_literal: true

require "cmd/assume-installed"
require "cmd/shared_examples/args_parse"

RSpec.describe Homebrew::Cmd::AssumeInstalled do
  it_behaves_like "parseable arguments"

  it "assumes a formula is installed", :integration_test do
    setup_test_formula "testball"

    expect { brew "assume-installed", "testball" }.to be_a_success
  end

  it "lists the assumed formulae when given no arguments" do
    AssumedInstalled.add("rust")

    expect { described_class.new([]).run }.to output(/rust/).to_stdout
  end

  it "drops the assumption once the formula is installed by Homebrew", :integration_test do
    setup_test_formula "testball"
    AssumedInstalled.add("testball")

    expect { brew "install", "--yes", "testball", "HOMEBREW_NO_INSTALL_FROM_API" => "1" }.to be_a_success
    expect(AssumedInstalled.include?("testball")).to be(false)
  end
end
