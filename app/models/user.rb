class User < ActiveRecord::Base
  acts_as_messageable

  has_one :profile, dependent: :destroy
  has_many :follow_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :follow_relationships, source: :followed
  accepts_nested_attributes_for :profile

  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "FollowRelationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships

  has_many :activities

  default_scope { includes(:profile, :activities) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  def following?(other_user)
    follow_relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    follow_relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    follow_relationships.find_by(followed_id: other_user.id).destroy
  end

  def mailboxer_email(object)
    return :email
  end

end
