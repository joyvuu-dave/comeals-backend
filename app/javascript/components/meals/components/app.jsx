import React from "react"
import { inject, observer } from "mobx-react"

import CookForm from "./cook_form"

const App = inject("store")(
    observer(({ store }) =>
        <div>
          <CookForm />
        </div>
    )
)

export default App

/*
WHAT THIS FILE DOES
1. Renders menu
    - provides links for opening books#index, cart#show
2. Renders page
    x books#index
    - books#show
    - cart#show
*/
