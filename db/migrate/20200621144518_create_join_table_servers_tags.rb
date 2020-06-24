# frozen_string_literal: true

class CreateJoinTableServersTags < ActiveRecord::Migration[6.0]
  def change
    create_table :servers_tags do |t|
      t.uuid :server_id, null: false
      t.bigint :tag_id, null: false
    end
  end
end
