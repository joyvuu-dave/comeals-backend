import React from 'react'
import { inject, observer } from 'mobx-react'
import DisplayDate from './display_date'

const Info = inject("store")(
  observer(({store}) =>
    <section>
      <DisplayDate />
      <table>
        <thead>
          <tr>
            <th>Attendees</th>
            <th>Guests</th>
            <th>Omnivores</th>
            <th>Vegetarians</th>
            <th>Late</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{store.attendeesCount}</td>
            <td>{store.guestsCount}</td>
            <td>{store.omnivoreCount}</td>
            <td>{store.vegetarianCount}</td>
            <td>{store.lateCount}</td>
          </tr>
        </tbody>
      </table>
    </section>
  )
)

export default Info
