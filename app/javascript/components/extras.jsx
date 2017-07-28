import React from 'react'
import { inject, observer } from 'mobx-react'

const Extras = inject("store")(
  observer(({store}) =>
    <div>
      <br />
      {store.meal.closed ?
        <label>Extras
          <input
            type="text"
            value={store.extras}
            onChange={e => store.meal.setExtras(e.target.value)}
            disabled={!store.meal.closed}
          />
          {store.meal.max !== null ? <span>{' '}Max:{store.meal.max}</span> : null}
        </label>
        :
        <label className="is-hidden"><input type="text" placeholder="Placeholder" /></label>
      }
    </div>
  )
)

export default Extras
