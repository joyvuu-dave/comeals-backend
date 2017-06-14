import React from 'react'
import axios from 'axios'

class Bill extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      resident_id: this.props.resident_id,
      amount: this.formatAmount(this.props.amount_cents)
    }

    this.handleSelectChange = this.handleSelectChange.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
  }

  handleSelectChange(event) {
    this.setState({
      resident_id: event.target.value
    })
  }

  handleInputChange(event) {
    this.setState({
      amount: event.target.value
    })
  }

  formatAmount(val) {
    if(Number.isInteger(val)) {
      return (val / 100).toFixed(2)
    }
  }

  render() {
    const self = this

    return(
      <div>
        <select value={this.state.resident_id} key={`select-${this.props.index}`} onChange={this.handleSelectChange}>
          <option value={-1} key={`option-${this.props.index}`}></option>
          {this.props.residents.map((resident) => <option value={resident.id} key={`${self.props.index}-${resident.id}`}>{resident.name}</option>)}
        </select>
        $<input type="text" value={this.state.amount} onChange={this.handleInputChange} />
        <br />
      </div>
    )
  }
}

export default Bill
