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
      @models_and_children ||= app_scoped_models.map { |m| [ m.table_name, m.reflections.values.select(&:belongs_to?).map(&:plural_name) ] }
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

      return order unless push_polymorphic_last

      polymorphic = polymorphic_dependent_tables(pairs, original_deps, nodes)

      # tables we will not handle
      unhandled = order.select { |t| %w[solid_ action_ oauth_ noticed_].any? { |prefix| t.start_with?(prefix) } }
      active_storage = order.select { |t| %w[active_storage].any? { |prefix| t.start_with?(prefix) } }

      # Stable partition
      dynamic = (order - active_storage).reject { |t| %w[tasks teams tenants users settings].include?(t) }
      non_poly = dynamic.reject { |t| polymorphic.include?(t) }
      poly     = dynamic.select { |t| polymorphic.include?(t) }
      # non_poly + poly + %w[users settings] - unhandled
      %w[tenants teams users] + non_poly + %w[tasks] + poly + %w[settings] + active_storage - unhandled
    end

    # Identify tables that should be pushed last:
    # 1) Have at least one dependency not present in the node set (likely polymorphic target name)
    # 2) OR the model has any polymorphic belongs_to reflection (column *_type/*_id)
    def polymorphic_dependent_tables(pairs, original_deps, nodes)
      Rails.application.eager_load! unless Rails.application.config.eager_load
      model_by_table = ApplicationRecord.descendants
        .select { |m| m.respond_to?(:table_name) rescue false }
        .index_by(&:table_name)

      tables = pairs.map(&:first)
      tables.select do |table|
        deps = original_deps[table] || []
        unknown_dep = deps.any? { |d| !nodes.include?(d) }
        poly_reflection =
          begin
            model = model_by_table[table]
            model &&
              model.reflections.values.any? { |r| r.belongs_to? && r.polymorphic? }
          rescue
            false
          end
        unknown_dep || poly_reflection
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
