import React from 'react'
import { inject, observer } from 'mobx-react'

const styles = {
  gridArea: 'a1',
  display: 'flex',
  justifyContent: 'space-between'
}

const ButtonBar = inject("store")(
  observer(({store}) =>
    <div style={styles}>
      <button className="button is-primary">Edit</button>
      <button className="button">History</button>
    </div>
  )
)

export default ButtonBar;
