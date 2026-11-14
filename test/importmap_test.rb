require "test_helper"

# `bin/importmap pin` can leave a vendored file importing a sibling it never downloaded,
# which breaks in the browser while every server-side check still passes.
class ImportmapTest < ActiveSupport::TestCase
  IMPORT = /(?:\bfrom|\bimport)\s*"([^"]+)"/

  def pinned
    Rails.application.importmap.packages.keys
  end

  test "every import in vendored JavaScript is pinned" do
    Rails.root.glob("vendor/javascript/**/*.js").each do |file|
      specifiers = file.read.scan(IMPORT).flatten.uniq

      specifiers.each do |specifier|
        assert_not specifier.start_with?(".", "/"), "#{file.relative_path_from(Rails.root)} imports #{specifier} by path; pin it and import by name"
        assert_includes pinned, specifier, "#{file.relative_path_from(Rails.root)} imports #{specifier}, which is not in config/importmap.rb"
      end
    end
  end

  test "Chart.js and its dependencies are pinned" do
    assert_includes pinned, "chart.js"
    assert_includes pinned, "@kurkle/color"
  end
end
