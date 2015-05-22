$( document ).ready(function() {

    $(".post").fitVids();
 
    $('.showcats').click(function( event ) {

      $('ul.tags').slideToggle();
      $(this).toggleClass('open');
      return false;

    });
 
});