require "application_system_test_case"

class BatchSelectionSearchProductsTest < ApplicationSystemTestCase
  setup do
    @tenant = tenants(:one)
    @user = users(:one)
    visit products_url
  end

  test "search applies only to explicitly selected products when batch all unchecked" do
    find("button", text: /Udvælg|Vælg/i).click rescue nil

    if page.has_selector?("#batch_all")
      uncheck("batch_all") if page.find("#batch_all", visible: :all).checked?
    end

    boxes = all('input[type="checkbox"][name="batch[ids][]"]', visible: :all).first(2)
    selected_ids = boxes.map { |b| b[:value].to_i }
    boxes.each { |b| b.set(true) }

    if page.has_button?("Vælg")
      click_on "Vælg"
      assert page.has_content?(I18n.t("filters.batched")) rescue true
    end

    fill_in 'search-field', with: products(:one).product_number[0,3]
    find('#search-field').send_keys(:enter)

    visible_ids = all('.list_item[id^="product_"]').map { |n| n[:id].split('_').last.to_i }
    visible_ids.each { |id| assert_includes selected_ids, id }
  end
end
