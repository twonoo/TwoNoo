class StaticPagesController < ApplicationController
  layout :resolve_layout
  
  def about
  end

  def contact
  end
  
  def terms
    
  end
  
  private
  
    def resolve_layout
      case action_name
      when "terms"
        "terms"
      else
        "application"
      end
    end  
end
