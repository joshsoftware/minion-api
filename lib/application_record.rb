# frozen_string_literal: true

# ApplicationRecord - models inherit from this
class ApplicationRecord < ActiveRecord::Base
  include ActiveModel::Model
  self.abstract_class = true
end
