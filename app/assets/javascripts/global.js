$(document).ready(function(){
  $('a').bind('click', function(e){
    if ($(this).attr('clicked') == 'true'){
      e.preventDefault();
    }
    $(this).attr('clicked', 'true');
  });

  $('#messages_link').dblclick(function(){
    window.location.href=$(this).attr('href');
  });

  prepare_follow_links();
});

function prepare_follow_links()
{
  $('.follow_link').bind('click', function(){
    div = $(this);
    div.unbind('click');
    div.find('a').html('Processing...');

    $.ajax({
      type: "GET",
      url: "/users/follow/" + $(this).attr('user_id'),
      success: function(html) {
        alert('You are now following ' + div.attr('user_name'));
        div.toggle();
      },
      error: function(e) {
      }
    });
  });
}

function trending_load() {

    "use strict";
    /*
    |--------------------------------------------------------------------------
    | PRELOADER
    |--------------------------------------------------------------------------
    */ 
    $('#status').fadeOut(); // will first fade out the loading animation
    $('#preloader').delay(350).fadeOut('slow'); // will fade out the white DIV that covers the website.
    $('body').delay(350).css({'overflow':'visible'});

    /*
    |--------------------------------------------------------------------------
    | ISOTOPE USAGE FILTERING
    |--------------------------------------------------------------------------
    */ 
    if($('.isotopeWrapper').length){

        var $container = $('.isotopeWrapper');
        var $resize = $('.isotopeWrapper').attr('id');
        // initialize isotope
        
        $container.isotope({
            itemSelector: '.isotopeItem',
            resizable: false, // disable normal resizing
            filter: '.top',
            masonry: {
                columnWidth: $container.width() / $resize
            }


            
        });
        var rightHeight = $('#works').height();
        $('#filter a').click(function(){


            $('#works').height(rightHeight);
            $('#filter a').removeClass('current');


            $(this).addClass('current');
            var selector = $(this).attr('data-filter');
            $container.isotope({
                filter: selector,
                animationOptions: {
                    duration: 1000,
                    easing: 'easeOutQuart',
                    queue: false
                }
            });
            return false;
        });
        
        
        $(window).smartresize(function(){
            $container.isotope({
                // update columnWidth to a percentage of container width
                masonry: {
                    columnWidth: $container.width() / $resize
                }
            });
        });
        

      }  


/**PROCESS ICONS**/
$('.iconBoxV3 a').hover(function() {

    if(Modernizr.csstransitions) {

        $(this).stop(false, true).toggleClass( 'hover', 150);
        $('i', this).css('-webkit-transform', 'rotateZ(360deg)');
        $('i', this).css('-moz-transform', 'rotateZ(360deg)');
        $('i', this).css('-o-transform', 'rotateZ(360deg)');
        $('i', this).css('transform', 'rotateZ(360deg)'); 

    }else{

       $(this).stop(false, true).toggleClass( 'hover', 150);

   }  

}, function() {

    if(Modernizr.csstransitions) {
        $(this).stop(false, true).toggleClass( 'hover', 150);
        $('i', this).css('-webkit-transform', 'rotateZ(0deg)');
        $('i', this).css('-moz-transform', 'rotateZ(0deg)');
        $('i', this).css('-o-transform', 'rotateZ(0deg)');
        $('i', this).css('transform', 'rotateZ(0deg)'); 

    }else{

        $(this).stop(false, true).toggleClass( 'hover', 150);
    }  
    
});


if($('.scrollMenu').length){


        if($('.localscroll').length){    
            $('.localscroll').localScroll({
                lazy: true,
                offset: {
                    top: - ($('#mainHeader').height() - 1)
                }
            });
        }

        var isMobile = false;

        if(Modernizr.mq('only all and (max-width: 1024px)') ) {
            isMobile = true;
        }

       
        if (isMobile === false && ($('#paralaxSlice1').length  ||isMobile === false &&  $('#paralaxSlice2').length ))
        {


            $(window).stellar({
                horizontalScrolling: false,
                responsive:true/*,
                scrollProperty: 'scroll',
                parallaxElements: false,
                horizontalScrolling: false,
                horizontalOffset: 0,
                verticalOffset: 0*/
            });

        }
  

    }


//END WINDOW LOAD
    if($('.imgHover').length){

        $('.imgHover article').hover(
            function () {

                var $this=$(this);

                var fromTop = ($('.imgWrapper', $this).height()/2 - $('.iconLinks', $this).height()/2);
                $('.iconLinks', $this).css('margin-top',fromTop);

                $('.mediaHover', $this).height($('.imgWrapper', $this).height());   

                $('.mask', this).css('height', $('.imgWrapper', this).height());
                $('.mask', this).css('width', $('.imgWrapper', this).width());
                $('.mask', this).css('margin-top', $('.imgWrapper', this).height());


                $('.mask', this).stop(1).show().css('margin-top', $('.imgWrapper', this).height()).animate({marginTop: 0},200, function() {

                    $('.iconLinks', $this).css('display', 'block');
                    if(Modernizr.csstransitions) {
                        $('.iconLinks a').addClass('animated');


                        $('.iconLinks a', $this).removeClass('flipOutX'); 
                        $('.iconLinks a', $this).addClass('bounceInDown'); 

                    }else{

                        $('.iconLinks', $this).stop(true, false).fadeIn('fast');
                    }


                });



            },function () {

                var $this=$(this);


                $('.mask', this).stop(1).show().animate({marginTop: $('.imgWrapper', $this).height()},200, function() {

                    if(Modernizr.csstransitions) {
                        $('.iconLinks a', $this).removeClass('bounceInDown'); 
                        $('.iconLinks a', $this).addClass('flipOutX'); 

                    }else{
                        $('.iconLinks', $this).stop(true, false).fadeOut('fast');
                    }

                });

            });
    }
}
