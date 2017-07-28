import React from 'react'
import { inject, observer } from 'mobx-react'

const Closed = inject("store")(
  observer(({store}) =>
    <button className={"button " + store.meal.closed ? "is-warning" : "is-success"} onClick={store.toggleClosed}>{store.meal.closed ? "Closed" : "Open"}</button>
  )
)

export default Closed
