require "test_helper"

class Editor::DocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "that document to_html interpolates {{ content }}" do
    document = Editor::Document.create!(tenant: tenants(:one), title: "Test Document")
    block = document.blocks.create!(type: "p", data: { text: "Hello, {{ tenant.name }}!" })
    html = document.to_html

    assert_includes html, "Hello, Danish Company!"
  end
end
