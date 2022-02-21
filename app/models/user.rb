class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_books, through: :favorites, source: :book

  has_many :messages, dependent: :destroy
  has_many :entries, dependent: :destroy

  # 自分がフォローする(与フォロー)側の関係性　フォローしたされたの関係
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # 自分がフォローされる(被フォロー)側の関係性
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # 与フォロー関係を通じて参照⇨自分がフォローしている人(一覧画面で使う)
  has_many :followings, through: :relationships, source: :followed
  # 被フォロー関係を通じて参照⇨自分をフォローしている人(一覧画面で使う)
  has_many :followers, through: :reverse_of_relationships, source: :follower

  # フォローしたときの処理
  def follow(user_id)
    # unless self == current_user
    relationships.create(followed_id: user_id) #.saveも入っている
    # end
  end
  # フォローを外すときの処理
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end
  # フォローしているか判定
  def following?(user)
    followings.include?(user)
  end


def self.search(search,word)
  if search == "forward_match"
    @user = User.where("name LIKE?","#{word}%")
  elsif search == "backward_match"
    @user = User.where("name LIKE?","%#{word}")
  elsif search == "perfect_match"
    @user = User.where(name: "#{word}")
  elsif search == "partial_match"
    @user = User.where("name LIKE?","%#{word}%")
  else
    @user = User.all
  end
end

  attachment :profile_image, destroy: false

  validates :name, presence:true, length: {maximum: 20, minimum: 2}, uniqueness: true
  validates :introduction, length: {maximum: 50}


  def self.guest
    # データの検索と作成を自動的に判断して処理を行う、Railsのメソッド
    # !」を付与することで、処理がうまくいかなかった場合にエラーが発生する
    find_or_create_by!(name:'guestuser', email:'guest@example.com') do |user|
      # ランダムな文字列を生成するRubyのメソッド
      user.password = SecureRandom.urlsafe_base64
      user.name = "guestuser"
    end
  end


end
