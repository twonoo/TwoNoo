class Interest < ActiveRecord::Base

  has_many :interests_options
  has_and_belongs_to_many :users

  before_create :generate_code

  validates_uniqueness_of :name, :code

  default_scope { where(:active => true) }

  private

  def generate_code

    self.code = self.name.split.map { |w| w[0] }.join
    10.times.each do |val|
      unless Interest.exists? code: self.code.upcase
        break
      end
      self.code += val.to_s
    end

  end

end
