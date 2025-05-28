require "application_system_test_case"

class Editor::BlocksTest < ApplicationSystemTestCase
  setup do
    @editor_block = editor_blocks(:one)
  end

  test "visiting the index" do
    visit editor_blocks_url
    assert_selector "h1", text: "Blocks"
  end

  test "should create block" do
    visit editor_blocks_url
    click_on "New block"

    fill_in "Data", with: @editor_block.data
    fill_in "Document", with: @editor_block.document_id
    fill_in "Parent", with: @editor_block.parent_id
    fill_in "Position", with: @editor_block.position
    fill_in "Type", with: @editor_block.type
    click_on "Create Block"

    assert_text "Block was successfully created"
    click_on "Back"
  end

  test "should update Block" do
    visit editor_block_url(@editor_block)
    click_on "Edit this block", match: :first

    fill_in "Data", with: @editor_block.data
    fill_in "Document", with: @editor_block.document_id
    fill_in "Parent", with: @editor_block.parent_id
    fill_in "Position", with: @editor_block.position
    fill_in "Type", with: @editor_block.type
    click_on "Update Block"

    assert_text "Block was successfully updated"
    click_on "Back"
  end

  test "should destroy Block" do
    visit editor_block_url(@editor_block)
    accept_confirm { click_on "Destroy this block", match: :first }

    assert_text "Block was successfully destroyed"
  end
end
