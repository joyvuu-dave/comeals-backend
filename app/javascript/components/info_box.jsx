import React from 'react'
import { inject, observer } from 'mobx-react'

const InfoBox = inject("store")(
  observer(({store}) =>
    <div className="meal-box info content">
      <h2>Attendees</h2>
      <ul>
        <li>Total: 13</li>
        <li>Veg: 4</li>
        <li>Late: 2</li>
      </ul>
    </div>
  )
)

export default InfoBox;
