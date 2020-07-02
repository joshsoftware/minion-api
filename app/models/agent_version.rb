# frozen_string_literal: true

class AgentVersion < ApplicationRecord
  validates :version, :md5, :file_path, presence: true

  def generate_file_digest
    Digest::MD5.file file_path
  end
end
