# frozen_string_literal: true

# Minion overall app
module Minion
  # Model is a submodule that we mix in to stuff in lib/models to avoid
  # duplication functionality/code unnecessarily
  module Model
    # To use data types provided by Dry::Types
    module Types
      include Dry.Types(default: :nominal)
      Dry::Types.load_extensions(:maybe)
    end

    # Automatically include Instance and Class methods when mixed-in
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    # InstanceMethods - these will be available on new instances of the class
    module InstanceMethods
      def destroy
        $pool.with do |conn|
          self.class.r.table(self.class::TABLE).get(id).delete.run(conn)
        end
      end
    end

    # ClassMethods - mixed in at the class level (e.g. User.count)
    module ClassMethods
      def count
        $pool.with do |conn|
          r.table(self::TABLE).count.run(conn)
        end
      end

      def find(id)
        $pool.with do |conn|
          hsh = r.table(self::TABLE).get(id).run(conn).deep_symbolize_keys
          return new(hsh)
        end
      end

      def create(hsh)
        hsh = hsh.with_indifferent_access.symbolize_keys
        # First, look for protected keys and remove their values
        self::PROTECTED_ATTRIBUTES.each do |prot|
          hsh.delete(prot)
        end

        # Set the created_at attribute to now
        hsh[:created_at] = Time.now.utc
        $pool.with do |conn|
          id = r.table(self::TABLE).insert(hsh).run(conn)['generated_keys'][0]
          return find(id)
        end
      end

      def r(*args)
        args == [] ? RethinkDB::RQL.new : RethinkDB::RQL.new.expr(*args)
      end
    end
  end
end
