class Micropost < ApplicationRecord
  MICROPOSTS_PARAMS = %i(content image).freeze

  belongs_to :user
  has_one_attached :image
  delegate :name, to: :user, prefix: :user

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.validations.post.content_length}
  validates :image,
            content_type: {
              in: Settings.validations.post.content_type,
              message: I18n.t("microposts.validate.image_format")
            },
            size: {
              less_than: Settings.validations.post.max_file_size.megabytes,
              message: I18n.t("microposts.validate.image_size")
            }

  delegate :name, to: :user, prefix: :user

  scope :order_by_created_at_desc, ->{order created_at: :desc}
  scope :users_feed, ->(ids){where user_id: ids}

  def display_image
    image.variant resize_to_limit: Settings.validations.post.resize_limit
  end
end
