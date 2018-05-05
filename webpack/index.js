import React from 'react'
import ReactDOM from 'react-dom'
import styles from './css/global.scss'
import App from './components/app'

document.addEventListener("DOMContentLoaded", function() {
  console.log("in DOMContentLoaded")
  const app = document.getElementById("app"), props = JSON.parse(app.getAttribute("react-props"))
  ReactDOM.render(React.createElement(App, props), app)

  const spinner = document.getElementById('app-loader')
  spinner.className = 'loaded'
})
