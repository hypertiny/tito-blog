$( document ).ready(function() {
 
    $('.showcats').click(function( event ) {

      $('ul.tags').slideToggle();
      $(this).toggleClass('open');
      return false;

    });
 
});