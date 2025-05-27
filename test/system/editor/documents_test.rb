require "application_system_test_case"

class Editor::DocumentsTest < ApplicationSystemTestCase
  setup do
    @editor_document = editor_documents(:one)
  end

  test "visiting the index" do
    visit editor_documents_url
    assert_selector "h1", text: "Documents"
  end

  test "should create document" do
    visit editor_documents_url
    click_on "New document"

    fill_in "Title", with: @editor_document.title
    click_on "Create Document"

    assert_text "Document was successfully created"
    click_on "Back"
  end

  test "should update Document" do
    visit editor_document_url(@editor_document)
    click_on "Edit this document", match: :first

    fill_in "Title", with: @editor_document.title
    click_on "Update Document"

    assert_text "Document was successfully updated"
    click_on "Back"
  end

  test "should destroy Document" do
    visit editor_document_url(@editor_document)
    accept_confirm { click_on "Destroy this document", match: :first }

    assert_text "Document was successfully destroyed"
  end
end
