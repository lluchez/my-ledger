$(document).on('turbolinks:load', function() {
  var $form = $("[data_type=form-statement-record-category]"), $select_type
  if( $form.length ) {
    var helpBtnCallbacks = {
      helpColor: function(event) {
        // TO DO: to be changed to open a popup instead
        window.open('https://www.w3schools.com/colors/colors_picker.asp', '_blank')
      },
      helpIcon: function(event) {
        // TO DO: to be changed to open a popup instead
        window.open('https://getbootstrap.com/docs/3.3/components/', '_blank')
      }
    }
    $form.find("[on-click-callback]").each( function(i, btn) {
      $(btn).on("click", helpBtnCallbacks[$(btn).attr("on-click-callback")].bind(btn))
    })
  }
})
