import React from 'react'
import { inject, observer } from 'mobx-react'

const styles = {
  border: '1px solid',
  gridArea: 'a5'
};

const InfoBox = inject("store")(
  observer(({store}) =>
    <div
      className="content"
      style={styles}
    >
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
