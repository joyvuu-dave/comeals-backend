import React from 'react'
import { inject, observer } from 'mobx-react'

const Meal = inject("store")(
  observer(({ store }) =>
    <div>
      {store.editMode ?
        <button onClick={e => store.submit()}>Submit</button>
        :
        <button onClick={e => store.toggleEditMode()}>Edit Meal</button>
      }
      <h4>Description</h4>
      {store.editMode ?
        <textarea value={store.description} onChange={e => store.setDescription(e.target.value)} />
        :
        <p>{store.description}</p>
      }
    </div>
  )
)

export default Meal
