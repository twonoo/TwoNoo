class ProfileDecorator < SimpleDelegator
  def display_name
    "#{first_name.capitalize} #{last_initial.capitalize}"
  end

  private

  def last_initial
    last_name.first
  end
end
