import React from 'react'
import { inject, observer } from 'mobx-react'

const Meal = inject("store")(
  observer(({ store }) =>
    <div>
      <h4>Description</h4>
      <textarea value={store.description} onChange={e => store.setDescription(e.target.value)} />
    </div>
  )
)

export default Meal
