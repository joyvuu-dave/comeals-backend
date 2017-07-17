import React from 'react'
import axios from 'axios'
import { inject, observer } from 'mobx-react'

class Bill extends React.Component {
  constructor(props) {
    super(props)

    this.handleResidentChange = this.handleResidentChange.bind(this)
    this.handleAmountChange = this.handleAmountChange.bind(this)
  }

  handleResidentChange(e) {
    const index = this.props.index
    const val = e.target.value
    this.props.store.currentMeal.updateBillResident(index, val)
  }

  handleAmountChange(e) {
    const index = this.props.index
    const val = e.target.value
    this.props.store.currentMeal.updateBillAmount(index, val)
  }

  formatAmount(val) {
    if(Number.isInteger(val)) {
      return (val / 100).toFixed(2)
    }
  }

  render() {
    const index = this.props.index
    const residents = this.props.store.currentMeal.currentResidents
    const bill = this.props.store.currentMeal.currentBills[index]

    return(
      <div>
        <select value={bill.currentAmountCents} key={`select-${this.props.index}`} onChange={this.handleResidentChange}>
          <option value={-1} key={`option-${this.props.index}`}></option>
          {residents.map((resident) => <option value={resident.currentId} key={`${self.props.index}-${resident.currentId}`}>{resident.currentName}</option>)}
        </select>
        $<input type="text" value={bill.currentAmountCents} onChange={this.handleAmountChange} />
        <br />
      </div>
    )
  }
}

export default observer(Bill)
