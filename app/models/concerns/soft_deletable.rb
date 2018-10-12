module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :deleted, -> { where.not(deleted_at: nil) }

    def deleted?
      deleted_at.present?
    end

    def delete
      update_attribute(:deleted_at, DateTime.now)
    end

    def restore
      update_attribute(:deleted_at, nil)
    end
  end
end
