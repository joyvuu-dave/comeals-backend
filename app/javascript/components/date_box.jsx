import React from 'react'
import { inject, observer } from 'mobx-react'

const DateBox = inject("store")(
  observer(({store}) =>
    <div className="meal-box date">
      <h2 className="title is-spaced">Sun, June 9</h2>
      <button className="button is-light subtitle">Calendar</button>
    </div>
  )
)

export default DateBox;
