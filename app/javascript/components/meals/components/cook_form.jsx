import React from 'react'
import axios from 'axios'
import Bill from './bill'
import Meal from './meal'
import { observer } from 'mobx-react'

class CookForm extends React.Component {

  renderRealBills() {
    const self = this
    return (
      <div>
        {self.props.store.bills.map((bill, index) => <Bill
          key={index}
          index={index}
          resident_id={bill.resident_id}
          amount_cents={bill.amount_cents}
          residents={self.props.store.residents} /> )}
      </div>
    )
  }

  renderDummyBills() {
    const self = this
    const dummyCount = Math.max(3 - this.props.store.bills.length, 0)

    return (
      <div>
        {Array.from(Array(dummyCount)).map((val, index) => <Bill
          key={index + self.props.store.bills.length}
          index={index + self.props.store.bills.length}
          residents={self.props.store.residents} /> )}
      </div>
    )
  }


  render() {
    return(
      <div>
        <h3>Cook Form</h3>
        <form>
          {this.renderRealBills()}
          {this.renderDummyBills()}
          <Meal
            store={this.props.store}
          />
        </form>
      </div>
    )
  }
}

export default observer(CookForm)
