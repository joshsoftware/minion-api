require 'json'

class Minion
  module JSONAble
    def to_json
      hsh = {}
      self.instance_variables.each do |v|
        hsh["#{v}".gsub(/@/, '')] = self.instance_variable_get v
      end
      return hsh.to_json
    end

    def from_json(str)
      hsh = JSON.load(str)
      self.instance_variables.each do |var|
        self.instance_variable_set var, hsh[var.to_s.gsub(/@/, '')]
      end
      return self
    end
  end
end
