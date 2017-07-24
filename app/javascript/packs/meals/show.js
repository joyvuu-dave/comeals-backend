import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'mobx-react'

import { DataStore } from '../../stores/data_store'

import Meal from '../../components/meal'
import Bills from '../../components/bills'
import Extras from '../../components/extras'
import Closed from '../../components/closed'
import Info from '../../components/info'
import AttendeeForm from '../../components/attendee_form'

document.addEventListener('DOMContentLoaded', () => {
  const node = document.getElementById('meal-id')
  const data = JSON.parse(node.getAttribute('data'))
  const id = Number.parseInt(data.id)
  const date = new Date(data.date)

  const store = DataStore.create({meal: id, meals: [{id: id, date: date}]})
  window.store = store

  // Enable pusher logging - don't include this in production
  Pusher.logToConsole = true;

  var pusher = new Pusher('8affd7213bb4643ca7f1', {
    cluster: 'us2',
    encrypted: true
  });

  var channel = pusher.subscribe(`meal-${id}`);
  channel.bind('update', function(data) {
    console.log(data.message);
    store.billStore.clear();
    store.residentStore.clear();
    store.loadDataAsync();
  });

  ReactDOM.render(
    <Provider store={store}>
      <div>
        <header>
          <button className="left" onClick={store.calendar}>Calendar</button>
          <button className="right" onClick={store.logout}>Logout</button>
        </header>
        <div id="subheader">
          <Info />
          <section className="cyan">
            <Closed />
            <Extras />
          </section>
        </div>
        <main>
          <section className="green">
            <Meal/>
            <h3>Cooks</h3>
            <Bills/>
          </section>
          <section className="yellow">
            <AttendeeForm />
          </section>
        </main>
      </div>
    </Provider>,
    document.getElementById("root")
  )
})
