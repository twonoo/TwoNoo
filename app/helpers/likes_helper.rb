module LikesHelper

  #It is important that non of the classes change on this.
  #Javascript uses it to make things work.
  #If you do need to change something, please also adjust likes.js.erb
  def like_button(activity_id)
   "<div class='like-widget' activity-id='#{activity_id}'>
   <span class='like-button'><span class='like-button-text'>Like</span></span>
               <span class='like-counter'>0</span>
   </div>".html_safe
 end

end