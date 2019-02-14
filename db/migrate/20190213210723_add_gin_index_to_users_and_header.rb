class AddGinIndexToUsersAndHeader < ActiveRecord::Migration[5.2]
  def up
    add_index :members, "to_tsvector('english', name )", using: :gin, name: 'members_name_idx'
    add_index :members, "to_tsvector('english', headers  )", using: :gin, name: 'headers_idx'
  end
  def down
    remove_index :members, :members_name_idx
    remove_index :members, :headers_idx
  end
end
