import React from 'react'
import { inject, observer } from 'mobx-react'

const Meal = inject("store")(
  observer(({ store }) =>
    <div>
      <label>Description
        <textarea value={store.description} onChange={e => store.setDescription(e.target.value)} />
      </label>
      <br />
      <label>Max
        <input type="text" value={store.max} onChange={e => store.setMax(e.target.value)} />
      </label>
      <br />
      <label>Closed
        <input type="checkbox" checked={store.closed} onChange={e => store.setClosed(e.target.checked)} />
      </label>
    </div>
  )
)

export default Meal
