import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'mobx-react'

import { FormStore } from '../../stores/form_store'

import Meal from '../../components/meal'
import Bills from '../../components/bills'
import AttendeeForm from '../../components/attendee_form'

document.addEventListener('DOMContentLoaded', () => {
  const node = document.getElementById('meal-id')
  const data = JSON.parse(node.getAttribute('data'))
  const id = Number.parseInt(data.id)

  const store = FormStore.create({meal: id, meals: [{id: id}]})
  window.store = store

  ReactDOM.render(
    <div>
      <Provider store={store}>
        <div>
          <h3>Cook Form</h3>
          <Meal/>
          <Bills/>
        </div>
      </Provider>
      <AttendeeForm meal_id={id} />
    </div>,
    document.getElementById("root")
  )
})
