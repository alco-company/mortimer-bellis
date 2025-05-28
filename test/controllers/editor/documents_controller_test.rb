require "test_helper"

class Editor::DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor_document = editor_documents(:one)
  end

  test "should get index" do
    get editor_documents_url
    assert_response :success
  end

  test "should get new" do
    get new_editor_document_url
    assert_response :success
  end

  test "should create editor_document" do
    assert_difference("Editor::Document.count") do
      post editor_documents_url, params: { editor_document: { title: @editor_document.title } }
    end

    assert_redirected_to editor_document_url(Editor::Document.last)
  end

  test "should show editor_document" do
    get editor_document_url(@editor_document)
    assert_response :success
  end

  test "should get edit" do
    get edit_editor_document_url(@editor_document)
    assert_response :success
  end

  test "should update editor_document" do
    patch editor_document_url(@editor_document), params: { editor_document: { title: @editor_document.title } }
    assert_redirected_to editor_document_url(@editor_document)
  end

  test "should destroy editor_document" do
    assert_difference("Editor::Document.count", -1) do
      delete editor_document_url(@editor_document)
    end

    assert_redirected_to editor_documents_url
  end
end
