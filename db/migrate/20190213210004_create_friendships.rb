class CreateFriendships < ActiveRecord::Migration[5.2]
  def change
    create_table :friendships do |t|
      t.integer :friender_id
      t.integer :friendee_id
    end
    add_index(:friendships, [:friender_id, :friendee_id], :unique => true)
    add_index(:friendships, [:friendee_id, :friender_id], :unique => true)
  end

end
