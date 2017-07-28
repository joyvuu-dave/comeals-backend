import React from 'react'
import { inject, observer } from 'mobx-react'


const Header = inject("store")(
  observer(({store}) =>
    <header style={styles}>
      <a className="navbar-item" onClick={store.logout}>Logout</a>
    </header>
  )
)

export default Header;


const styles = {
  display: 'flex',
  justifyContent: 'flex-end',
  height: '35px',
  backgroundColor: 'var(--hasana-yellow)'
}
