require "application_system_test_case"

class TagComponentTest < ApplicationSystemTestCase
  setup do
    @tenant = tenants(:one)
    @user = users(:superadmin)
    Current.system_user = @user
  end

  test "the tag to have an input field, albeit hidden" do
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment
    assert_match "<input type=\"hidden\"", output.to_s
  end

  test "the tag to have a turbo_frame " do
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment
    assert_match "<turbo-frame id=\"#{Current.get_user.id}_tag", output.to_s
  end

  test "the tag to have a label" do
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment, show_label: true
    assert_match "<label", output.to_s
  end

  test "the tag to have a lookup container" do
    tags = Tag.all
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment, resources: tags, search: "do"
    assert_match "<ul id=\"time_material-task_comment-lookup-container\"", output.to_s
    assert_match tags(:one).name, output.to_s
  end

  test "the tag to have a lookup container with no exact matching tag" do
    tags = Tag.all
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment, resources: tags, search: "no_tags"
    assert_match "<ul id=\"time_material-task_comment-lookup-container\"", output.to_s
    assert_match "Tilføj", output.to_s
  end

  test "the tag to have a selected container with a selected tag" do
    tags = []
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment, resources: tags, value: [ tags(:one) ]
    assert_match "<div id=\"time_material-task_comment-selected-container\"", output.to_s
    assert_match "data-id=\"#{tags(:one).id}\"", output.to_s
    assert_match tags(:one).name, output.to_s
  end

  test "the tag to always have a context" do
    tags = []
    output = render TagComponent.new resource: TimeMaterial.new, field: :task_comment, resources: tags, value: [ tags(:one) ]
    assert_match "data-context=\"TimeMaterial\"", output.to_s
  end
end
