# typed: strict
# frozen_string_literal: true

require "install"
require "dependency"
require "test/support/fixtures/testball"

RSpec.describe Homebrew::Install do
  specify "::perform_preinstall_checks runs non-fatal preinstall diagnostics" do
    allow(described_class).to receive(:check_prefix)
    allow(described_class).to receive(:check_cpu)
    allow(described_class).to receive(:attempt_directory_creation)

    expect(Homebrew::Diagnostic).to receive(:checks)
      .with(:supported_configuration_checks, fatal: false)
      .ordered
    expect(Homebrew::Diagnostic).to receive(:checks)
      .with(:preinstall_checks, fatal: false)
      .ordered
    expect(Homebrew::Diagnostic).to receive(:checks)
      .with(:fatal_preinstall_checks)
      .ordered

    described_class.send(:perform_preinstall_checks)
  end

  describe "::print_dry_run_dependencies" do
    it "splits fresh installs and updates under separate headers" do
      fresh = formula("fresh-dep") do
        T.bind(self, T.class_of(Formula))
        url "foo-1.0"
      end
      outdated = formula("outdated-dep") do
        T.bind(self, T.class_of(Formula))
        url "foo-1.0"
      end
      allow(fresh).to receive_messages(any_version_installed?: false, outdated?: false,
                                       latest_version_installed?: false)
      allow(outdated).to receive_messages(any_version_installed?: true, outdated?: true,
                                          latest_version_installed?: false)
      deps = [
        instance_double(Dependency, to_formula: fresh),
        instance_double(Dependency, to_formula: outdated),
      ]

      expect { described_class.print_dry_run_dependencies(Testball.new, deps, &:name) }
        .to output(/Would install 1 dependency.*fresh-dep.*Would update 1 dependency.*outdated-dep/m).to_stdout
    end

    it "marks an unlinked current-version dependency as a reinstall under the update header" do
      dependency = formula("reinstall-dep") do
        T.bind(self, T.class_of(Formula))
        url "foo-1.0"
      end
      allow(dependency).to receive_messages(any_version_installed?: true, outdated?: true,
                                            latest_version_installed?: true)
      dep = instance_double(Dependency, to_formula: dependency)

      expect { described_class.print_dry_run_dependencies(Testball.new, [dep], &:name) }
        .to output(/Would update 1 dependency.*reinstall-dep \(reinstall\)/m).to_stdout
    end
  end
end
