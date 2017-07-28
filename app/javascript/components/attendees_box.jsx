import React from 'react'
import { inject, observer } from 'mobx-react'

const AttendeesBox = inject("store")(
  observer(({store}) =>
    <div id="attendees">
      <button className="button is-warning">Close</button>
      <table className="table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Attending</th>
            <th>Late</th>
            <th>Veg</th>
            <th>Guests</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Bowen</td>
            <td><input type="checkbox" className="checkbox-inout" /></td>
            <td><input type="checkbox" className="checkbox-inout" /></td>
            <td><input type="checkbox" className="checkbox-inout" /></td>
            <td>0</td>
            <td>
              <button className="button is-small is-success">+ Guest</button>{' '}
              <button className="button is-small is-warning">- Guest</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  )
)

export default AttendeesBox;
