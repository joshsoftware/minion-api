# frozen_string_literal: true

class AgentVersion < ApplicationRecord
  validates :version, :md5, :url, presence: true
end
