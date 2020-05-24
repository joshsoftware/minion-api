module Minion
  module Model
    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def to_json
        hsh = {}
        self.instance_variables.each do |v|
          hsh["#{v}".gsub(/@/, '')] = self.instance_variable_get v
        end
        return hsh.to_json
      end

      def destroy
        $pool.with do |conn|
          self.class.r.table(self.class::TABLE).get(self.id).delete().run(conn)
        end
      end
    end

    module ClassMethods
      def count
        $pool.with do |conn|
          r.table(self::TABLE).count().run(conn)
        end
      end

      def from_json(str)
        hsh = JSON.load(str)
        thing = self.new
        thing.instance_variables.each do |var|
          thing.instance_variable_set var, hsh[var.to_s.gsub(/@/, '')]
        end
        return thing
      end

      def find(id)
        $pool.with do |conn|
          return self.from_json(r.table(self::TABLE).get(id).run(conn).to_json)
        end
      end

      def create(thing)
        # First, look for protected keys and remove their values
        thing.class::PROTECTED_METHODS.each do |prot|
          if thing.instance_variables.include?(prot)
            thing.instance_variable_set(prot, nil)
          end
        end

        # Set the created_at attribute to now
        if thing.instance_variables.include?(:@created_at)
          thing.created_at = Time.now.utc
        end

        hsh = JSON.parse(thing.to_json)
        hsh.delete('id')
        $pool.with do |conn|
          id = r.table(thing.class::TABLE).insert(hsh).run(conn)['generated_keys'][0]
          return thing.class.find(id)
        end
        # TODO: Somehow get the user or at least their ID back from this stmt
      end

      def r(*args)
        args == [] ? RethinkDB::RQL.new : RethinkDB::RQL.new.expr(*args)
      end
    end
  end
end


def self.find(id)
  $pool.with do |conn|
    u = User.from_json(r.table("users").get(id).run(conn).to_json)
    return u
  end
  # return User.new.from_json((r.table("users").get(id).run($r)).to_json)
end
