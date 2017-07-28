import React from 'react'
import { inject, observer } from 'mobx-react'

const Header = inject("store")(
  observer(({store}) =>
    <header>
      <nav className="navbar-menu is-active">
        <div className="navbar-end">
          <a className="navbar-item" onClick={store.logout}>Logout</a>
        </div>
      </nav>
    </header>
  )
)

export default Header;
