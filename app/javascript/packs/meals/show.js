import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'mobx-react'

import { DataStore } from '../../stores/data_store'

import Meal from '../../components/meal'
import Bills from '../../components/bills'
import AttendeeForm from '../../components/attendee_form'

document.addEventListener('DOMContentLoaded', () => {
  const node = document.getElementById('meal-id')
  const data = JSON.parse(node.getAttribute('data'))
  const id = Number.parseInt(data.id)
  const date = new Date(data.date)

  const store = DataStore.create({meal: id, meals: [{id: id, date: date}]})
  window.store = store

  ReactDOM.render(
    <Provider store={store}>
      <div>
        <header>
          <a href="/calendar">Calendar</a>{' '}
          <button onClick={store.logout}>Logout</button>
        </header>
        <main>
          <section>
            <Meal/>
            <h3>Cooks</h3>
            <Bills/>
          </section>
          <section>
            <AttendeeForm />
          </section>
        </main>
      </div>
    </Provider>,
    document.getElementById("root")
  )
})
