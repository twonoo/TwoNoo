class Activity < ActiveRecord::Base
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
		where('activity_name LIKE ? OR location_name LIKE ? OR description LIKE ?', "%#{terms}%", "%#{terms}%", "%#{terms}%")
	end

end