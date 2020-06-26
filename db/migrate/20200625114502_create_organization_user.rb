class CreateOrganizationUser < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_users do |t|
      t.uuid :organization_id, type: :uuid, null: false, index: true
      t.uuid :user_id, type: :uuid, null: false, index: true
    end
  end
end
