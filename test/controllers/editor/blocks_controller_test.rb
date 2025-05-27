require "test_helper"

class Editor::BlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor_block = editor_blocks(:one)
  end

  test "should get index" do
    get editor_blocks_url
    assert_response :success
  end

  test "should get new" do
    get new_editor_block_url
    assert_response :success
  end

  test "should create editor_block" do
    assert_difference("Editor::Block.count") do
      post editor_blocks_url, params: { editor_block: { data: @editor_block.data, document_id: @editor_block.document_id, parent_id: @editor_block.parent_id, position: @editor_block.position, type: @editor_block.type } }
    end

    assert_redirected_to editor_block_url(Editor::Block.last)
  end

  test "should show editor_block" do
    get editor_block_url(@editor_block)
    assert_response :success
  end

  test "should get edit" do
    get edit_editor_block_url(@editor_block)
    assert_response :success
  end

  test "should update editor_block" do
    patch editor_block_url(@editor_block), params: { editor_block: { data: @editor_block.data, document_id: @editor_block.document_id, parent_id: @editor_block.parent_id, position: @editor_block.position, type: @editor_block.type } }
    assert_redirected_to editor_block_url(@editor_block)
  end

  test "should destroy editor_block" do
    assert_difference("Editor::Block.count", -1) do
      delete editor_block_url(@editor_block)
    end

    assert_redirected_to editor_blocks_url
  end
end
