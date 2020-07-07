class ChangeAddressesToString < ActiveRecord::Migration[6.0]
  def change
    change_column :servers, :addresses, :string, array: true, default: [], null: false
  end
end
