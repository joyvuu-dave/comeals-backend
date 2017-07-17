/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'meals' %> to the appropriate
// layout file, like app/views/layouts/meals.html.erb


import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'mobx-react'

import App from 'components/meals/components/app'

import { FormStore } from 'components/meals/models/form_store'

const store = FormStore.create()
window.store = store

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <Provider store={store}>
        <App />
      </Provider>,
      document.getElementById("root")
  )
})
