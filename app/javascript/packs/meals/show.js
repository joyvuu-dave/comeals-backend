import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'mobx-react'

import { DataStore } from '../../stores/data_store'

import Header from '../../components/header'
import Meal from '../../components/meal'
import Bills from '../../components/bills'
import Extras from '../../components/extras'
import Closed from '../../components/closed'
import Info from '../../components/info'
import AttendeeForm from '../../components/attendee_form'
import ButtonBar from '../../components/button_bar'
import DateBox from '../../components/date_box'
import MenuBox from '../../components/menu_box'
import CooksBox from '../../components/cooks_box'
import InfoBox from '../../components/info_box'
import AttendeesBox from '../../components/attendees_box'

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

    if (store.billStore && store.billStore.bills) {
      store.billStore.bills.clear();
    }
    if (store.residentStore && store.residentStore.residents) {
      store.residentStore.residents.clear();
    }

    store.loadDataAsync();
  });

  ReactDOM.render(
    <Provider store={store}>
      <div>
        <Header />
        <main style={styles.main}>
          <section style={styles.section}>
            <div style={styles.meal}>
              <ButtonBar />
              <DateBox />
              <MenuBox />
              <CooksBox />
              <InfoBox />
            </div>
          </section>
          <section style={styles.section}>
            <AttendeesBox />
          </section>
        </main>
      </div>
    </Provider>,
    document.getElementById("root")
  )
})

/* Flex container, centered content*/
const styles = {
  main: {
    display: 'flex',
    alignItems: 'center',
    flexDirection: 'column',
    minWidth: 'var(--page-width)'
  },
  section: {
    width: 'var(--page-width)',
    margin: '1em 0 1em 0'
  },
  meal: {
  height: 'var(--section-height)',
  display: 'grid',
  gridGap: '20px',
  gridTemplateColumns: 'repeat(12, 1fr)',
  gridTemplateRows: '25px 1fr 1fr',
  gridTemplateAreas:
   `"a1 a1 .   .  .  .   .  .  .   .  .  . "
    "a2 a2 a2  a2 a3 a3  a3 a3 a3  a3 a3 a3"
    "a4 a4 a4  a4 a4 a4  a5 a5 a5  a5 a5 a5"`
  }
};
