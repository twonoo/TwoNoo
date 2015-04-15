module LikesHelper

  def like_button(activity_id)
   "<div class='like-widget' activity-id='#{activity_id}'>
   <span class='like-button'><span class='like-button-text'>Like</span></span>
               <span class='like-counter'>0</span>
   </div>".html_safe
 end

end