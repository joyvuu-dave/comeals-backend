import React from 'react'
import { inject, observer } from 'mobx-react'

const DisplayDate = inject("store")(
  observer(({store}) =>
      <h3>
        {store.meal.date.toDateString()}
      </h3>
  )
)

export default DisplayDate;
