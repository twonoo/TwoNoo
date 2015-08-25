class ProfileDecorator < SimpleDelegator
  def display_name
    "#{first_name.capitalize} #{last_initial.capitalize}"
  end

  def initials
    "#{first_initial.capitalize}#{last_initial.capitalize}"
  end

  def last_initial
    last_name.first
  end

  private

  def first_initial
    first_name.first
  end
end
