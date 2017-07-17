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
    <Provider store={store}>
      <div>
        <a href="/calendar">Calendar</a>{' '}
        <button onClick={store.logout}>Logout</button>
        <h3>Cooks</h3>
        <Meal/>
        <Bills/>
        <AttendeeForm meal_id={id} />
      </div>
    </Provider>,
    document.getElementById("root")
  )
})
