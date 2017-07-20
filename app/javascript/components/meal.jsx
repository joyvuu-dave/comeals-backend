import React from 'react'
import { inject, observer } from 'mobx-react'

const Meal = inject("store")(
  observer(({ store }) =>
    <div>
      <h3>
        {store.meal.date.toDateString()}
      </h3>

      <h4>Description</h4>
      <textarea value={store.description} onChange={e => store.setDescription(e.target.value)} />

      <h4>Extras</h4>
      <input type="text" value={store.extras} onChange={e => store.meal.setExtras(e.target.value)} disabled={!store.meal.closed} />{' '}(Max:{' '}{store.meal.max ? store.meal.max : 'not set'}){' '}{!store.meal.maxIsValid && <span>Error</span>}

      <h4>Closed</h4>
      <input type="checkbox" checked={store.meal.closed} onChange={e => store.setClosed(e.target.checked)} />

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
    </div>
  )
)

export default Meal
