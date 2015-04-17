class Activity < ActiveRecord::Base
  acts_as_commentable

  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "100x75>", :map_image => "250x100#", :trending => "650x500#"}, :default_url => "#{ENV['BASEURL']}/no-image.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  belongs_to :user
  has_many :likes
  has_and_belongs_to_many :activity_types
  #geocoded_by :address
  before_validation :geocodecache
  before_save :assign_timezone
  before_save :convert_to_datetime
  before_save :convert_to_enddatetime
  before_save :format_url
  before_save :format_description
  has_many :rsvps

  validates :activity_name, :date, :time, :city, :state, :description, presence: true

  validates_format_of :time, :with => /\A[ ]?([1-9]|1[0-2]|0[1-9]):[0-5][0-9] (AM|PM)\Z/i, :message => 'Invalid'
  validates_format_of :endtime, :with => /\A[ ]?([1-9]|1[0-2]|0[1-9]):[0-5][0-9] (AM|PM)\Z/i, :message => 'Invalid', unless: "endtime.blank?"

  #validate :distance_cannot_be_greater_than_100_miles
  validate :end_not_more_than_30_days
  validate :presence_of_activity_types

  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  scope :between_dates, lambda { |from_date, end_date| where('(datetime BETWEEN ? AND ?) OR (enddatetime BETWEEN ? AND ?) OR ((? < enddatetime) AND (? > datetime))',
                                                             from_date, end_date, from_date, end_date, from_date, end_date) }

  scope :after_date, lambda { |from_date| where('(datetime > ?) OR (enddatetime > ?) ',
                                                from_date, from_date) }
  scope :upcoming, lambda { where("datetime >= ?", Time.now()) }

  def address
    [street_address_1, street_address_2, city, state].grep(String).join(', ')
  end

  def increase_view
    if views.nil?
      update_attribute(:views, 1)
    else
      update_attribute(:views, views + 1)
    end
  end

  def date
    begin
      unless @date.nil?
        Time.strptime("#{@date}", "%m/%d/%Y")
      else
        @date = datetime.strftime("%m/%d/%Y")
      end
    rescue => e
      errors[:base] << "#{@date} is not a valid date. Use the format MM/DD/YYYY" unless @date.blank?
    end

    return @date

  end

  def date=(d)
    logger.info "date: #{d}"
    @date = d
  end

  def enddate
    begin
      if !(@enddate.nil?)
        Time.strptime("#{@enddate}", "%m/%d/%Y")
      elsif self.enddatetime.nil?
        return nil
      else
        @enddate = self.enddatetime.strftime("%m/%d/%Y")
      end
    rescue => e
      errors[:base] << "#{@enddate} is not a valid date. Use the format MM/DD/YYYY" unless @enddate.blank?
    end

    return @enddate

  end

  def enddate=(d)
    logger.info "enddate: #{d}"
    @enddate = d
  end

  def time
    begin
      unless @time.nil?
        Time.parse(@time)
      else
        @time = datetime.strftime("%l:%M %p")
      end
    rescue
      errors[:base] << "#{@time} is not a valid time" unless @time.blank?
    end

    return @time
  end

  def time=(t)
    logger.info "time: #{t}"
    @time = t
    logger.info "time2: #{t}"
  end

  def endtime
    begin
      if !(@endtime.nil?)
        Time.zone.parse(@endtime)
      elsif self.enddatetime.nil?
        return nil
      else
        @endtime = self.enddatetime.strftime("%l:%M %p")
      end
    rescue
      errors[:base] << "#{@endtime} is not a valid time" unless @endtime.blank?
    end

    return @endtime
  end

  def endtime=(t)
    @endtime = t
  end

  def convert_to_datetime
    unless @date.blank? || @time.blank?
      logger.info "time3: #{@time}"
      logger.info "zone: #{Time.zone}"
      tz = ActiveSupport::TimeZone['Mountain Time (US & Canada)']
      time_in_tz = tz.parse(Time.strptime("#{@date} #{@time.lstrip}", "%m/%d/%Y %l:%M %p").strftime('%Y-%m-%d %H:%M:%S'))
      self.datetime = time_in_tz
      logger.info "datetime: #{self.datetime}"
    end
  end

  def convert_to_enddatetime
    unless @enddate.blank? || @endtime.blank?
      logger.info "endtime: #{@endtime}"
      tz = ActiveSupport::TimeZone['Mountain Time (US & Canada)']
      time_in_tz = tz.parse(Time.strptime("#{@enddate} #{@endtime.lstrip}", "%m/%d/%Y %l:%M %p").strftime('%Y-%m-%d %H:%M:%S'))
      self.enddatetime = time_in_tz
      logger.info "enddatetime: #{self.enddatetime}"
    end
  end

  def end_not_more_than_30_days
    unless enddatetime.nil? || (datetime - enddatetime) < 30.days
      errors[:base] << "End date cannot be more than 30 days after the start"
    end
  end

  def distance_cannot_be_greater_than_100_miles
    unless city.blank?
      denver = [39.737567, -104.9847179]
      pittsburgh = [40.44062479999999, -79.9958864]
      fairbanks = [64.8377778, -147.7163889]

      #unless distance_from("Denver, CO") < 100 || distance_from("Pittsburgh, PA") < 100
      unless (distance_from(denver) < 300 || distance_from(pittsburgh) < 100 || distance_from(fairbanks) < 600) then
        errors[:base] << "Whoops! #{city} is not within our current network, but will be soon!" + distance_from(fairbanks).to_s
      end
    end
  end

  def geocodecache
    logger.info "geocodecache"
    geocode = Geocode.where(city: city).where(state: state).first

    if latitude.blank? || longitude.blank?
      # for some reason we don't have the latlon
      unless geocode.nil? then
        self.latitude = geocode.latitude
        self.longitude = geocode.longitude
      else
        # Look up the latlong by citysate
        search_coordinates = Geocoder.search(params[:location]).first.coordinates

        self.latitude = search_coordinates.latitude
        self.longitude = search_coordinates.longitude
      end
    end

    if geocode.nil? then
      # let's assume we don't have the timezone
      timezone = Timezone::Zone.new(:latlon => [latitude, longitude])

      # insert the geocode
      geocode = Geocode.new(city: city, state: state, latitude: latitude, longitude: longitude,
                            timezone: timezone.active_support_time_zone)

      logger.info "save it"
      geocode.save
    end
  end

  def self.terms(terms)
    query = []
    terms.split.each do |t|
      query << "(activity_name LIKE '%#{t}%' OR location_name LIKE '%#{t}%' OR description LIKE '%#{t}%' OR street_address_1 LIKE '%#{t}%' OR street_address_2 LIKE '%#{t}%' OR city LIKE '%#{t}%' OR state LIKE '%#{t}%' OR website LIKE '%#{t}%')"
    end
    where(query.join(" AND "))
  end

  def self.trending(location)
    denver = [39.737567, -104.9847179]
    pittsburgh = [40.44062479999999, -79.9958864]
    fairbanks = [64.8377778, -147.7163889]

    where('datetime > ?', Time.now.utc)
    .select('activities.*, COUNT(rsvps.id) as rsvp_count')
    .where(cancelled: false)
    .within(100, origin: (location.nil? ? denver : location))
    .joins(:rsvps)
    .group(:id)
    .order('rsvp_count DESC')
    .limit(16)
  end

  private

  def presence_of_activity_types
    unless activity_types.present?
      errors[:base] << 'Please add at least one keyword'
    end
  end

  def get_coordinates
    unless self.latitude.nil? or self.longitude.nil? then
      return [self.latitude, self.longitude]
    end

    return fetch_coordinates
  end

  def get_timezone
    # first, see if the timezone is already in the db
    geocode = Geocode.where(latitude: latitude).where(longitude: longitude).first

    if geocode.nil? then
      # we had a cache miss
      zone = Timezone::Zone.new(:latlon => get_coordinates)
      timezone = zone.active_support_time_zone
    else
      return geocode.timezone
    end

    return timezone
  end

  def assign_timezone
    self.tz = get_timezone
  end

  def format_url
    if self.website.present?
      if (self.website =~ /\Ahttp[s]?/i).nil?
        self.website = "http://#{self.website}"
      end
      logger.info "format_url: #{self.website}"
    end
  end

  def format_description
    logger.info "format_description"
    if self.description.present?
      logger.info "description before: #{self.description}"
      self.description = self.description.gsub(/<[^>]*>/, '') #remove all html tags
      logger.info "description after: #{self.description}"
    end
  end


end
