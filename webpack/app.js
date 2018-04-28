import React from 'react'
import ReactDOM from 'react-dom'
import Test from './components/test.jsx'


document.addEventListener("DOMContentLoaded", function() {
  const main = document.getElementById("main")
  ReactDOM.render(React.createElement(Test, {}), main)
})

