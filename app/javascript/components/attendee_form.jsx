import React from 'react'
import axios from 'axios'
import { inject, observer } from 'mobx-react'

const AttendeeComponent = inject("store")(
  observer(({ store, resident }) =>
    <tr>
      <td>{resident.name}</td>
      <td><input type="checkbox" checked={resident.attending} onChange={e => resident.setAttending(e.target.checked)} disabled={!store.canAdd || (resident.attending && store.meal.closed)} /></td>
      <td><input type="checkbox" checked={resident.late} onChange={e => resident.setLate(e.target.checked)} disabled={!resident.attending} /></td>
      <td><input type="checkbox" checked={resident.vegetarian} onChange={e => resident.setVegetarian(e.target.checked)} disabled={store.meal.closed || !resident.attending} /></td>
      <td>
        <button onClick={e => resident.addGuest()} disabled={!store.canAdd} >Add</button>{resident.guests}
        <button onClick={e => resident.removeGuest()} disabled={store.meal.closed || resident.guests === 0}>Remove</button>
      </td>
    </tr>
  )
)

const AttendeeForm = inject("store")(
  observer(({ store }) =>
    <div>
      <h3>Attendees</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Attending</th>
            <th>Late</th>
            <th>Veg</th>
            <th>Guests</th>
          </tr>
        </thead>
        <tbody>
          {store.residents.values().map(resident => <AttendeeComponent key={resident.id} resident={resident} />)}
        </tbody>
      </table>
    </div>
  )
)

export default AttendeeForm
