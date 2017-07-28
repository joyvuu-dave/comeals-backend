import React from 'react'
import { inject, observer } from 'mobx-react'

const MenuBox = inject("store")(
  observer(({store}) =>
    <div className="meal-box menu">
      <div className="menu-title">Menu</div>
      <div className="menu-text">Crawfish etoufe, beer, other</div>
    </div>
  )
)

export default MenuBox;
