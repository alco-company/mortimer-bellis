require "test_helper"

class DependencyGraphTest < ActiveSupport::TestCase
  test "restore_order parents before children and purge reverses" do
    order = DependencyGraph.restore_order
    purge = DependencyGraph.purge_order
    assert_equal order.reverse, purge, "purge_order should be reverse of restore_order"

    if (order & %w[Customer Project Invoice]).size == 3
      assert order.index('Customer') < order.index('Project'), 'Customer before Project'
      assert order.index('Customer') < order.index('Invoice'), 'Customer before Invoice'
    end
    if (order & %w[Product InvoiceItem]).size == 2
      assert order.index('Product') < order.index('InvoiceItem'), 'Product before InvoiceItem'
    end
    if (order & %w[Team User ProvidedService]).size == 3
      assert order.index('Team') < order.index('User'), 'Team before User'
      assert order.index('User') < order.index('ProvidedService'), 'User before ProvidedService'
    end
  end
end
