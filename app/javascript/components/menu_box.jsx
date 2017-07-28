import React from 'react'
import { inject, observer } from 'mobx-react'

const styles = {
  border: '1px solid',
  gridArea: 'a3',
  display: 'grid',
  gridTemplateRows: '1fr 4fr'
};

const MenuBox = inject("store")(
  observer(({store}) =>
    <div style={styles}>
      <div>Menu</div>
      <div>Crawfish etoufe, beer, other</div>
    </div>
  )
)

export default MenuBox;
