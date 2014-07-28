require "the_friendly_id/version"

module TheFriendlyId
  class Engine < Rails::Engine; end
end

# friendly_id h11149+menu-10-u-5  # uniq
# short_id    h11149              # uniq
# id          50                  # uniq

module TheFriendlyId
  module Base
    extend ActiveSupport::Concern

    SEPARATOR = "+"

    def self.int? str
      str.to_s.to_i.to_s == str
    end

    def self.friendly? str
      Regexp.new("\\#{TheFriendlyId::Base::SEPARATOR}") =~ str
    end

    def self.short? str
      str =~ /^[A-Z]+[0-9]+$/mix
    end

    included do
      def to_param; self.slug end

      validates_presence_of   :short_id, :friendly_id
      validates_uniqueness_of :short_id, :slug

      before_validation :build_short_id
      before_validation :build_slugs

      def friendly_prefix
        {
          hub:    :h,
          page:   :p,
          post:   :pt,
          blog:   :b,
          recipe: :r,
          note:   :n
        }
      end

      def build_short_id
        return unless self.short_id.blank?
        klass  = self.class.to_s.downcase.to_sym
        prefix = friendly_prefix[klass]

        # build short id
        prefix  ||= 'x'
        rnd_num   = 9999
        short_id  = [prefix, rand(rnd_num)].join

        # rebuild if find identically short_id
        try_counter = 0
        while self.class.where(short_id: short_id).first
          short_id = [prefix, rand(rnd_num)].join
          try_counter = try_counter + 1
          break if try_counter > (rnd_num/10)
        end

        # set short_id
        self.short_id = short_id
      end

      def build_slugs
        unless self.title.blank?
          _slug = slug.blank? ? title : slug
          _slug = title if title_changed?
          _slug = slug  if slug_changed? && !slug.blank?

          self.slug        = uniq_slug(_slug)
          self.friendly_id = [self.short_id, self.slug].join TheFriendlyId::Base::SEPARATOR
        end
      end

      def uniq_slug str
        _slug = str.to_s.to_slug_param

        10.times do |i|
          objs_with_this_slug = self.class.where(slug: _slug)
          break if objs_with_this_slug.size.zero?
          break if objs_with_this_slug.size == 1 && objs_with_this_slug.include?(self)
          _slug = [str, i.next].join('-').to_s.to_slug_param
        end

        _slug
      end
    end

    module ClassMethods
      def friendly_where id
        if TheFriendlyId::Base.int?(id)
          where(id: id)
        elsif id.is_a? Array
          ids = id.map(&:to_slug_param)
          where(slug: ids)
        elsif TheFriendlyId::Base.friendly?(id)
          where(friendly_id: id)
        elsif TheFriendlyId::Base.short?(id)
          by_slug = where(slug: id.to_slug_param)
          by_slug.present? ? by_slug : where(slug: id.to_slug_param)
        else
          where(slug: id.to_slug_param)
        end
      end

      def friendly_first id
        friendly_where(id).first
      end
    end
  end
end
