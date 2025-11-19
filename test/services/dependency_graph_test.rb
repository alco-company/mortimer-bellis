require "test_helper"

class DependencyGraphTest < ActiveSupport::TestCase
  # Test 1: Basic order properties
  test "restore_order is reverse of purge_order" do
    restore = DependencyGraph.restore_order
    purge = DependencyGraph.purge_order

    assert_equal restore.reverse, purge,
      "purge_order should be exact reverse of restore_order"
  end

  # Test 2: All tables have dependencies properly ordered
  test "all tables have dependencies before them in restore order" do
    restore_order = DependencyGraph.restore_order
    models_and_deps = DependencyGraph.models_and_children.to_h

    # Build position lookup
    position = {}
    restore_order.each_with_index { |table, idx| position[table] = idx }

    violations = []
    models_and_deps.each do |table, dependencies|
      next unless position[table] # Skip tables not in restore order

      dependencies.each do |dep|
        next unless position[dep] # Skip dependencies not in restore order (e.g., polymorphic)

        if position[dep] >= position[table]
          violations << "#{table} (pos #{position[table]}) depends on #{dep} (pos #{position[dep]}) but #{dep} comes AFTER #{table}"
        end
      end
    end

    assert_empty violations,
      "Found dependency violations:\n#{violations.join("\n")}"
  end

  # Test 3: Tenant is first
  test "tenants table is first in restore order" do
    restore_order = DependencyGraph.restore_order
    assert_equal "tenants", restore_order.first,
      "tenants must be first since all other tables reference it"
  end

  # Test 4: Specific critical dependencies
  test "critical dependencies are correctly ordered" do
    restore_order = DependencyGraph.restore_order
    position = {}
    restore_order.each_with_index { |table, idx| position[table] = idx }

    # Core tenant dependencies
    if position["tenants"] && position["teams"]
      assert position["tenants"] < position["teams"],
        "tenants must come before teams"
    end

    if position["tenants"] && position["users"]
      assert position["tenants"] < position["users"],
        "tenants must come before users"
    end

    if position["teams"] && position["users"]
      assert position["teams"] < position["users"],
        "teams must come before users (users.team_id)"
    end

    # Invoice chain
    if position["customers"] && position["projects"]
      assert position["customers"] < position["projects"],
        "customers must come before projects"
    end

    if position["customers"] && position["invoices"]
      assert position["customers"] < position["invoices"],
        "customers must come before invoices"
    end

    if position["products"] && position["invoice_items"]
      assert position["products"] < position["invoice_items"],
        "products must come before invoice_items"
    end

    if position["invoices"] && position["invoice_items"]
      assert position["invoices"] < position["invoice_items"],
        "invoices must come before invoice_items"
    end

    # Location-based
    if position["locations"] && position["punch_clocks"]
      assert position["locations"] < position["punch_clocks"],
        "locations must come before punch_clocks"
    end

    if position["punch_clocks"] && position["punches"]
      assert position["punch_clocks"] < position["punches"],
        "punch_clocks must come before punches"
    end

    if position["punch_cards"] && position["punches"]
      assert position["punch_cards"] < position["punches"],
        "punch_cards must come before punches"
    end

    # User-dependent tables
    if position["users"] && position["background_jobs"]
      assert position["users"] < position["background_jobs"],
        "users must come before background_jobs"
    end

    if position["users"] && position["batches"]
      assert position["users"] < position["batches"],
        "users must come before batches"
    end

    if position["users"] && position["provided_services"]
      assert position["users"] < position["provided_services"],
        "users must come before provided_services (authorized_by_id)"
    end

    if position["users"] && position["tags"]
      assert position["users"] < position["tags"],
        "users must come before tags (created_by_id)"
    end

    # Calendar chain
    if position["calendars"] && position["events"]
      assert position["calendars"] < position["events"],
        "calendars must come before events"
    end

    if position["events"] && position["event_meta"]
      assert position["events"] < position["event_meta"],
        "events must come before event_meta"
    end

    # Editor documents
    if position["editor_documents"] && position["editor_blocks"]
      assert position["editor_documents"] < position["editor_blocks"],
        "editor_documents must come before editor_blocks"
    end
  end

  # Test 5: No cycles
  test "dependency graph has no cycles" do
    restore_order = DependencyGraph.restore_order
    models_and_deps = DependencyGraph.models_and_children.to_h

    # If there are cycles, some tables won't be in the order
    # or they'll be at the end with a warning
    expected_tables = models_and_deps.keys.reject { |t|
      # Exclude framework tables that might not be in order
      %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) }
    }

    # All expected tables should be in the restore order
    missing = expected_tables - restore_order
    assert_empty missing,
      "Tables missing from restore_order (possible cycle): #{missing.join(', ')}"
  end

  # Test 6: Purge order allows safe deletion
  test "purge order allows deletion without FK violations" do
    purge_order = DependencyGraph.purge_order
    models_and_deps = DependencyGraph.models_and_children.to_h

    # Build position lookup
    position = {}
    purge_order.each_with_index { |table, idx| position[table] = idx }

    violations = []

    # In purge order, children should come BEFORE parents
    # (delete children first, then parents)
    models_and_deps.each do |table, dependencies|
      next unless position[table]

      dependencies.each do |dep|
        next unless position[dep]

        # In PURGE, table should come BEFORE its dependencies
        if position[table] >= position[dep]
          violations << "#{table} (pos #{position[table]}) depends on #{dep} (pos #{position[dep]}) but #{table} should be purged BEFORE #{dep}"
        end
      end
    end

    assert_empty violations,
      "Found purge order violations (children must be deleted before parents):\n#{violations.join("\n")}"
  end

  # Test 7: Backup order is sensible
  test "backup_order excludes framework tables" do
    backup = DependencyGraph.backup_order

    # Should not include solid_*, action_*, oauth_*, noticed_*
    framework_tables = backup.select { |t|
      %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) }
    }

    assert_empty framework_tables,
      "backup_order should exclude framework tables: #{framework_tables.join(', ')}"
  end

  # Test 8: Polymorphic tables are identified
  test "polymorphic tables are correctly identified" do
    poly = DependencyGraph.polymorphic_tables

    # Known polymorphic tables
    known_polymorphic = %w[
      taggings
      settings
      calendars
    ]

    known_polymorphic.each do |table|
      assert_includes poly, table,
        "#{table} should be identified as polymorphic"
    end
  end
end
