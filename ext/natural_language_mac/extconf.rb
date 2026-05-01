# frozen_string_literal: true

require "swift_gem/mkmf"

SwiftGem::Mkmf.create_swift_makefile(
  "natural_language_mac/natural_language_mac",
  package: "NaturalLanguageMac",
  source_dir: __dir__
)
