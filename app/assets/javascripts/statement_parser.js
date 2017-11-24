"option strict"

$(document).on('turbolinks:load', function() {
  var $form = $("[data_type=form-statement-parser]"), $select_type
  if( $form.length ) {
    var callback = function(event) {
      var val = $(this).val()
      $form.find("[data-type=conditional-section]").hide()
      if( val )
        $form.find("[show-when-type-is="+val+"]").show()
    }

    var $select_type = $form.find("#statement_parsers_parser_base_type").on("change", callback)
    callback.call($select_type)

    var helpBtnCallbacks = {
      regexpFormat: function(event) {
        // TO DO: to be changed to open a popup instead
        window.open('https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions', '_blank')
      },
      helpRubyDateFormat: function(event) {
        // TO DO: to be changed to open a popup instead
        window.open('https://ruby-doc.org/stdlib-2.1.1/libdoc/date/rdoc/Date.html#method-i-strftime', '_blank')
        //window.open('https://ruby-doc.org/stdlib-2.1.1/libdoc/date/rdoc/Date.html#method-c-_strptime', '_blank')
      }
    }
    $form.find("[on-click-callback]").each( function(i, btn) {
      $(btn).on("click", helpBtnCallbacks[$(btn).attr("on-click-callback")].bind(btn))
    })
  }
})
