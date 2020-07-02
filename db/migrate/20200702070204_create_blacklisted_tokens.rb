class CreateBlacklistedTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :token, index: true
      t.timestamps
    end
  end
end
