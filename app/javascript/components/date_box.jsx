import React from 'react'
import { inject, observer } from 'mobx-react'

const styles = {
  border: '1px solid',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  flexDirection: 'column',
  gridArea: 'a2'
};

const DateBox = inject("store")(
  observer(({store}) =>
    <div style={styles}>
      <h2 className="title is-spaced">Sun, June 9</h2>
      <button className="button is-light subtitle">Calendar</button>
    </div>
  )
)

export default DateBox;
