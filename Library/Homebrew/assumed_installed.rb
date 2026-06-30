# typed: strict
# frozen_string_literal: true

require "fileutils"
require "executables_db"

# Registry of formulae the user has declared as provided outside Homebrew.
#
# Such formulae are pruned from dependency resolution so Homebrew never
# installs or builds them, and the directories holding the externally-provided
# tools are added to from-source build `PATH`s so they can be found.
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

  sig { returns(T::Array[String]) }
  def self.bin_paths
    return [] if none?

    executables = Homebrew::ExecutablesDB.new((HOMEBREW_CACHE/"api/internal/executables.txt").to_s).to_hash
    formulae.flat_map do |name|
      executables.fetch(name, []).filter_map { |command| which(command, ORIGINAL_PATHS)&.dirname }
    end.map(&:to_s).uniq
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
