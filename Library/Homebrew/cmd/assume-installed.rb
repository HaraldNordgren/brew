# typed: strict
# frozen_string_literal: true

require "abstract_command"
require "assumed_installed"
require "formula"

module Homebrew
  module Cmd
    class AssumeInstalled < AbstractCommand
      cmd_args do
        description <<~EOS
          Record the specified <formula> as provided outside Homebrew, so it is
          pruned from dependency resolution and never installed or built. The
          login `PATH` is made available to from-source builds so the
          externally-provided tools can be found. See also `unassume`.

          With no arguments, list the formulae currently assumed to be installed.

          *Note:* this is intended for build-only dependencies (e.g. a `rust`
          toolchain managed by `rustup`). Assuming a linked runtime dependency
          will likely produce a broken install.
        EOS

        named_args :formula
      end

      sig { override.void }
      def run
        if args.no_named?
          assumed = AssumedInstalled.formulae
          puts assumed unless assumed.empty?
          return
        end

        args.named.to_formulae.each do |formula|
          if AssumedInstalled.include?(formula.name)
            opoo "#{formula.name} already assumed installed"
          else
            AssumedInstalled.add(formula.name)
          end
        end
      end
    end
  end
end
