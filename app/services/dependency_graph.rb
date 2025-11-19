require "set"
class DependencyGraph
  class << self
    def app_scoped_models
      Rails.application.eager_load! unless Rails.application.config.eager_load
      # @app_scoped_models ||= ActiveRecord::Base.descendants.select { |m| (m.table_exists? rescue false) }.sort_by(&:name)
      ActiveRecord::Base.descendants.select { |m| m.respond_to? :table_name }
        .compact.uniq
        .reject { |t| t.abstract_class? }
      # .map { |m| m.table_name }
      # @app_scoped_models ||= ApplicationRecord.descendants.select do |m|
      #   next if !m.table_exists? rescue false
      #   true
      # end.sort_by(&:name)
    end

    def app_tenant_associations(id)
      DependencyGraph.app_scoped_models.filter { |t|  t.new.respond_to?(:tenant_id) rescue false }.map do |t|
        t.where tenant_id: id
      end.compact.flatten
    end

    def models_and_children
      @models_and_children ||= app_scoped_models.map do |m|
        dependencies = m.reflections.values.select(&:belongs_to?).map do |reflection|
          # For polymorphic associations, we can't determine the table, use plural_name
          if reflection.polymorphic?
            reflection.plural_name
          else
            # Use the actual table name from the reflection's class
            begin
              dep_table = reflection.klass.table_name
              # Skip self-referential associations (would create cycles)
              dep_table == m.table_name ? nil : dep_table
            rescue
              # Fallback to plural_name if klass can't be determined
              reflection.plural_name
            end
          end
        end.compact.uniq

        [ m.table_name, dependencies ]
      end
    end

    # there are two kinds of unique indexes,
    # those that incorporate the ID of the record
    # and those that operate on a subset of columns - like users.unlock_token
    # and this function focuses on the second one
    #
    def field_unique_indexes(table)
      is = ActiveRecord::Base.connection.indexes(table).filter { |i| i.unique }.map(&:columns).compact.flatten
      is.filter { |c| c =~ /_id/ || c =~ /_type/ }.any? ? [] : is
    end

    def restore_order(push_polymorphic_last: true)
      pairs = models_and_children
      topo_sort(pairs, push_polymorphic_last:)
    end

    # backup order: all tables with tenant_id first, then others (e.g. active_storage)
    def backup_order
      r = restore_order
      r = r.reject { |t| %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) } }
      r.reject { |t| %w[active_storage].any? { |prefix| t.start_with?(prefix) } } # + r.select { |t| %w[active_storage].any? { |prefix| t.start_with?(prefix) } }
    end

    def purge_order
      restore_order.reverse
    end

    def polymorphic_tables
      pairs = models_and_children
      original_deps = pairs.to_h
      nodes = pairs.map(&:first).to_set
      polymorphic_dependent_tables(pairs, original_deps, nodes)
        .reject { |t| %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) } }
    end

    # deps_pairs = [
    #   ["background_jobs", ["tenants", "users"]],
    #   ["batches", ["tenants", "users"]],
    #   ...
    #   ["teams", ["tenants"]],
    #   ["tenants", []],
    #   ["time_materials", ["tenants", "customers", "projects", "products", "users"]],
    #   ["users", ["tenants", "teams", "invited_bies"]]
    # ]

    # Enhanced topo_sort:
    # - Performs normal topological sort
    # - Detects “polymorphic dependent” tables (those whose dependency list
    #   contained names not present as nodes OR whose model has a polymorphic belongs_to)
    # - Moves those tables to the end (stable order preserved) if push_polymorphic_last
    def topo_sort(pairs, push_polymorphic_last: false)
      nodes = pairs.map(&:first).to_set
      # Keep original deps for polymorphic detection
      original_deps = pairs.to_h

      # Dependencies restricted to known nodes for the actual graph
      cleaned = pairs.map { |n, deps| [ n, deps.select { |d| nodes.include?(d) } ] }.to_h

      # indegree count
      indegree = Hash.new(0)
      nodes.each { |n| indegree[n] = 0 }
      cleaned.each do |n, deps|
        deps.each { |d| indegree[n] += 1 }
      end

      # adjacency
      adj = Hash.new { |h, k| h[k] = [] }
      cleaned.each do |n, deps|
        deps.each { |d| adj[d] << n }
      end

      queue = indegree.select { |_, v| v.zero? }.keys.sort
      order = []

      until queue.empty?
        cur = queue.shift
        order << cur
        adj[cur].each do |child|
          indegree[child] -= 1
            if indegree[child] == 0
            queue << child
            queue.sort!
            end
        end
      end

      if order.length < nodes.length
        remaining = (nodes - order).to_a
        warn "Cycle or unresolved dependencies among: #{remaining.inspect}"
        order += remaining
      end

      # Remove framework tables that we don't want to backup/restore
      order = order.reject { |t| %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) } }

      # Ensure critical tenant-related tables are at the front in the right order
      # This is important for backup/restore operations
      critical_order = %w[tenants teams users]
      critical_present = order & critical_order
      other_tables = order - critical_order

      critical_present + other_tables
    end

    # Identify tables that should be pushed last:
    # 1) Have at least one dependency not present in the node set (likely polymorphic target name)
    #
    # Note: We used to also push tables that HAVE polymorphic associations to the end,
    # but this breaks dependency chains. For example, 'calendars' is polymorphic but
    # 'events' depends on it, so calendars must come before events.
    #
    # Only push tables that depend on UNKNOWN/EXTERNAL tables (like 'records' which
    # doesn't exist as a concrete table but is a polymorphic target).
    def polymorphic_dependent_tables(pairs, original_deps, nodes)
      Rails.application.eager_load! unless Rails.application.config.eager_load

      tables = pairs.map(&:first)
      tables.select do |table|
        deps = original_deps[table] || []
        # Only push to end if this table depends on something that doesn't exist
        deps.any? { |d| !nodes.include?(d) }
      end.to_set
    end
  end

  # def tenant_scoped_models
  #   Rails.application.eager_load! unless Rails.application.config.eager_load
  #   @tenant_scoped_models ||= ApplicationRecord.descendants.select do |m|
  #     next if !m.table_exists? rescue false
  #     m.column_names.include?("tenant_id")
  #   end.sort_by(&:name)
  # end

  # def dependent_models
  #   @dependent_models ||= app_scoped_models - tenant_scoped_models - [ Tenant ]
  # end

  # def foreign_key_edges
  #   Rails.application.eager_load! unless Rails.application.config.eager_load
  #   conn = ActiveRecord::Base.connection
  #   adapter = conn.adapter_name.downcase
  #   table_to_model = tenant_scoped_models.to_h { |m| [ m.table_name, m ] }
  #   edges = Hash.new { |h, k| h[k] = [] }
  #   tenant_scoped_models.each do |model|
  #     table = model.table_name
  #     fks = []
  #     begin
  #       if adapter.include?("sqlite")
  #         conn.execute("PRAGMA foreign_key_list(#{table})").each do |row|
  #           parent_table = row["table"] rescue row[2] rescue nil
  #           fks << parent_table if parent_table
  #         end
  #       else
  #         if conn.respond_to?(:foreign_keys)
  #           conn.foreign_keys(table).each { |fk| fks << fk.to_table }
  #         end
  #       end
  #     rescue => e
  #       Rails.logger.debug { "FK inspect failed for #{table}: #{e.message}" }
  #     end
  #     fks.uniq.each do |parent_table|
  #       parent_model = table_to_model[parent_table]
  #         next unless parent_model
  #       edges[parent_model.name] << model.name unless edges[parent_model.name].include?(model.name)
  #     end
  #   end
  #   edges
  # end
end
