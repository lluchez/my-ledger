import React from 'react'
import ReactDOM from 'react-dom'
import styles from './css/global.scss'
import App from './components/app'

document.addEventListener("DOMContentLoaded", function() {
  console.log("in DOMContentLoaded")
  const app = document.getElementById("app")
  console.log('app', app)
  ReactDOM.render(React.createElement(App, {}), app)
})
