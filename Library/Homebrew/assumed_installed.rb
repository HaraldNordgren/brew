# typed: strict
# frozen_string_literal: true

require "fileutils"

# Registry of formulae the user has declared as provided outside Homebrew.
#
# Such formulae are pruned from dependency resolution so Homebrew never
# installs or builds them, and the user's login `PATH` is made available to
# from-source builds so the externally-provided tools can be found.
#
# This is intended for build-only dependencies (e.g. a `rust` toolchain managed
# by `rustup`). Assuming a linked runtime dependency will likely produce a
# broken install, since Homebrew won't find its headers or libraries.
module AssumedInstalled
  sig { returns(T::Array[String]) }
  def self.formulae
    return [] unless HOMEBREW_ASSUMED_INSTALLED.directory?

    HOMEBREW_ASSUMED_INSTALLED.children.select(&:file?).map { it.basename.to_s }.sort
  end

  sig { params(name: String).returns(T::Boolean) }
  def self.include?(name)
    (HOMEBREW_ASSUMED_INSTALLED/name).file?
  end

  sig { returns(T::Boolean) }
  def self.any?
    HOMEBREW_ASSUMED_INSTALLED.directory? && HOMEBREW_ASSUMED_INSTALLED.children.any?(&:file?)
  end

  sig { returns(T::Boolean) }
  def self.none? = !any?

  sig { params(name: String).void }
  def self.add(name)
    HOMEBREW_ASSUMED_INSTALLED.mkpath
    FileUtils.touch(HOMEBREW_ASSUMED_INSTALLED/name)
  end

  sig { params(name: String).void }
  def self.remove(name)
    (HOMEBREW_ASSUMED_INSTALLED/name).unlink
    HOMEBREW_ASSUMED_INSTALLED.rmdir_if_possible
  end
end
