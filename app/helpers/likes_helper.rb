module LikesHelper

  def like_button(activity_id)
    "<div class='like-widget' activity-id='#{activity_id}'>
    <a href='#' class='like-button'></a>
                <span class='like-counter'>0</span>
    </div>".html_safe
  end

end