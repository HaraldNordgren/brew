# typed: true
# frozen_string_literal: true

require "assumed_installed"

RSpec.describe AssumedInstalled do
  it "is not included before being added" do
    expect(described_class.include?("rust")).to be(false)
  end

  it "records a formula as assumed installed" do
    described_class.add("rust")
    expect(described_class.include?("rust")).to be(true)
  end

  it "lists assumed formulae sorted" do
    described_class.add("rust")
    described_class.add("go")
    expect(described_class.formulae).to eq(["go", "rust"])
  end

  it "reports any? once a formula is added" do
    described_class.add("rust")
    expect(described_class.any?).to be(true)
  end

  it "removes a recorded formula" do
    described_class.add("rust")
    described_class.remove("rust")
    expect(described_class.include?("rust")).to be(false)
  end
end
