class InterestsOption < ActiveRecord::Base

  belongs_to :interest

  before_create :generate_code

  validates_uniqueness_of :code

  default_scope { where(active: true) }

  private

  def generate_code

    10.times.each do |val|
      self.code = self.option_name[0] + self.option_value.split.map { |w| w[0] }.join
      unless Interest.exists? code: self.code.upcase
        break
      end
      self.code += val.to_s
    end

  end

end