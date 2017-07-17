import React from 'react'
import Bill from './bill'
import { inject, observer } from 'mobx-react'

class Bills extends React.Component {
  render() {
    const store = this.props.store
    const bills = store.currentMeal.currentBills

    let components = null
    components = bills.map((bill, index) =>
        <Bill
          key={index}
          index={index}
          store={store}
        />
    )

    return (
      <div>
        {components}
      </div>
    )
  }
}

export default observer(Bills)
