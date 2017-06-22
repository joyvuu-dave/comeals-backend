import React from 'react'
import { observer } from 'mobx-react'

class Meal extends React.Component {
  constructor(props) {
    super(props)

    this.handleDescriptionChange = this.handleDescriptionChange.bind(this)
    this.handleMaxChange = this.handleMaxChange.bind(this)
    this.handleClosedChange = this.handleClosedChange.bind(this)
  }

  handleDescriptionChange(event) {
    this.props.store.setDescription(event.target.value)
  }

  handleMaxChange(event) {
    this.props.store.setMax(Number(event.target.value))
  }

  handleClosedChange(event) {
    this.props.store.setClosed(event.target.checked)
  }

  render() {
    return(
      <div>
        <label>Description
          <textarea value={this.props.store.description} onChange={this.handleDescriptionChange} />
        </label>
        <br />
        <label>Max
          <input type="text" value={this.props.store.max === 0 ? '' : this.props.store.max} onChange={this.handleMaxChange} />
        </label>
        <br />
        <label>Closed
          <input type="checkbox" checked={this.props.store.closed} onChange={this.handleClosedChange} />
        </label>
      </div>
    )
  }
}

export default observer(Meal)
