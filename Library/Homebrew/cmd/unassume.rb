# typed: strict
# frozen_string_literal: true

require "abstract_command"
require "assumed_installed"

module Homebrew
  module Cmd
    class Unassume < AbstractCommand
      cmd_args do
        description <<~EOS
          Stop assuming the specified <formula> is provided outside Homebrew,
          so Homebrew installs and builds it as a dependency again. See also
          `assume-installed`.
        EOS

        named_args :formula, min: 1
      end

      sig { override.void }
      def run
        args.named.each do |name|
          if AssumedInstalled.include?(name)
            AssumedInstalled.remove(name)
          else
            opoo "#{name} not assumed installed"
          end
        end
      end
    end
  end
end
