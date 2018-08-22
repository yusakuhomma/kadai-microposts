class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :favourites
  has_many :likes, through: :favourites, source: :micropost
  

  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end


  def like(like_micropost)
    unless self.id == like_micropost.user_id
      self.favourites.find_or_create_by(user_id: self.id, micropost_id: like_micropost.id)
    end
  end
  
  def unlike(like_micropost)
    favourite = self.favourites.find_by(user_id: self.id, micropost_id: like_micropost.id)
    favourite.destroy if favourite
  end
  
  def liking?(like_micropost)
    self.likes.include?(like_micropost)
  end

  def feed_likes
    Micropost.where(user_id: self.like_ids + [self.id])
  end
end