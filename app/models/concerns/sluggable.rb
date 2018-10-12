module Sluggable
  extend ActiveSupport::Concern

  class_methods do
    def find(input)
      if (input.to_i.to_s == input.to_s)
        find_by(id: input.to_i)
      else
        find_by(slug: input)
      end
    end
  end

  included do
    before_create :generate_slug

    def generate_slug(force=false)
      self.slug = SecureRandom.urlsafe_base64 if slug.nil? || force
    end

    def to_param
      slug
    end
  end
end
