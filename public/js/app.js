$(document).ready(function() { 
  $(document).on("submit", ".navbar-form.try", function(e){
    var input = $(this).find(".form-control.try");
    var pattern = new RegExp(/^[1-6]{4}$/)
    if (!pattern.test(input.val())){
      e.preventDefault(e);
      input.val('');
      $(this).addClass("has-error");
    }    
  });
});