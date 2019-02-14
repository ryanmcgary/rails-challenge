class Member < ApplicationRecord
  has_and_belongs_to_many :friends, 
                          class_name: "Member", 
                          join_table: :friendships, 
                          foreign_key: :friender_id, 
                          association_foreign_key: :friendee_id

  # Make sure bi-directional binding is enforced
  after_save do |p|
    friends.each do |e|
      if !Friendship.find_by(friendee_id: p.id, friender_id: e.id)
        Friendship.create!(friendee_id: p.id, friender_id: e.id)
      end
    end
    Friendship.where(friendee_id: p.id).where.not(friender_id: p.friends.ids).delete_all
  end

end
