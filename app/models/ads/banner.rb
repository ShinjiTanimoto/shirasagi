class Ads::Banner
  include Cms::Page::Model
  include SS::Relation::File
  include Cms::Addon::Release

  field :link_url, type: String

  belongs_to_file :file

  before_save :seq_filename, if: ->{ basename.blank? }

  validates :link_url, presence: true
  #validates :file_id, presence: true

  permit_params :link_url

  default_scope ->{ where(route: "ads/banner") }

  public
    def url
      super + "?#{link_url}"
    end

    def count_url
      url.sub(".html", ".html.count")
    end

  private
    def validate_filename
      @basename.blank? ? nil : super
    end

    def seq_filename
      self.filename = dirname ? "#{dirname}#{id}.html" : "#{id}.html"
    end
end
