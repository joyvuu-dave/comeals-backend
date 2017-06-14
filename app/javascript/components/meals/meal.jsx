import React from 'react'

class Meal extends React.Component {
  constructor(props) {
    super(props)

    this.handleDescriptionChange = this.handleDescriptionChange.bind(this)
    this.handleMaxChange = this.handleMaxChange.bind(this)
    this.handleClosedChange = this.handleClosedChange.bind(this)
  }

  handleDescriptionChange(event) {
    console.log(event.target.value)
  }

  handleMaxChange(event) {
    console.log(event.target.value)
  }

  handleClosedChange(event) {
    console.log(event.target.value)
  }

  render() {
    return(
      <div>
        <label>Description
          <textarea value={this.props.description} onChange={this.handleDescriptionChange} />
        </label>
        <br />
        <label>Max
          <input type="text" value={this.props.max} onChange={this.handleMaxChange} />
        </label>
        <br />
        <label>Closed
          <input type="checkbox" checked={this.props.closed} onChange={this.handleClosedChange} />
        </label>
      </div>
    )
  }
}

export default Meal
