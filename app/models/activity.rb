class Activity < ActiveRecord::Base
	acts_as_commentable

	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x75>", :map_image => "250x100#" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
	belongs_to :user
	has_and_belongs_to_many :activity_types
	geocoded_by :address
	after_validation :geocode

	acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

	def address
		[street_address_1, street_address_2, city, state].reject!(&:empty?).join(', ')
	end

	def self.terms(terms)
		query = []
		terms.split.each do |t|
			query << "(activity_name LIKE '%#{t}%' OR location_name LIKE '%#{t}%' OR description LIKE '%#{t}%')"
		end
		where(query.join(" AND "))
	end

end
