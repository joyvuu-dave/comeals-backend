import React from 'react'
import { inject, observer } from 'mobx-react'

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
    return (
      <div>
        {this.props.store.loaded ?
          <div>
            <label>Description
              <textarea value={this.props.store.meal.description} onChange={this.handleDescriptionChange} />
            </label>
            <br />
            <label>Max
              <input type="text" value={this.props.store.meal.max} onChange={this.handleMaxChange} />
            </label>
            <br />
            <label>Closed
              <input type="checkbox" checked={this.props.store.meal.closed} onChange={this.handleClosedChange} />
            </label>
          </div>
          :
          <h2>Loading meal...</h2>
        }
      </div>
    )
  }
}

export default observer(Meal)
