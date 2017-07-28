import React from 'react'
import { inject, observer } from 'mobx-react'

const ButtonBar = inject("store")(
  observer(({store}) =>
    <div className="button-bar">
      <button className="button is-primary">Edit</button>
      <button className="button">History</button>
    </div>
  )
)

export default ButtonBar;
