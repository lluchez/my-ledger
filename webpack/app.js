import React from 'react'
import ReactDOM from 'react-dom'
import Dashboard from './components/dashboard.jsx'

function init() {
  function getComponent(className) {
    return {
      Dashboard
    }[className]
  }

  $('div[data-react-class]').each( (i,node) => {
    const $node = $(node),
      className = $node.attr("data-react-class"),
      props = JSON.parse($node.attr('data-react-props') || '{}'),
      component = getComponent(className)
    if( component )
      ReactDOM.render(React.createElement(component, props), node)
  })
}


// document.addEventListener("DOMContentLoaded", init)
$(document).on('turbolinks:load', init)
