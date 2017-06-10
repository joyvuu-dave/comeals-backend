import React from 'react'

class AttendeeComponent extends React.Component {
  constructor(props) {
    super(props)
    this.handleAttendClick = this.handleAttendClick.bind(this)
    this.handleLateClick = this.handleLateClick.bind(this)
    this.handleVegClick = this.handleVegClick.bind(this)
    this.handleGuestAdd = this.handleGuestAdd.bind(this)
    this.handleGuestRemove = this.handleGuestRemove.bind(this)
  }

  handleAttendClick(event) {
    if(event.target.checked) {
      window.alert(`${this.props.resident.name} wants to attend!`)
    } else {
      window.alert(`${this.props.resident.name} no longer wants to attend!`)
    }
  }

  handleLateClick(event) {
    if(event.target.checked) {
      window.alert(`${this.props.resident.name} will be late!`)
    } else {
      window.alert(`${this.props.resident.name} will NOT be late!`)
    }
  }

  handleVegClick(event) {
    if(event.target.checked) {
      window.alert(`${this.props.resident.name} needs a vegetarian dish!`)
    } else {
      window.alert(`${this.props.resident.name} wants meat!`)
    }
  }

  handleGuestAdd() {
    window.alert(`${this.props.resident.name} will be bring a guest!`)
  }

  handleGuestRemove() {
    window.alert(`${this.props.resident.name} is bringing one less guest!`)
  }

  render() {
    return(
      <div>
        <label>{this.props.resident.name}
          <input type="checkbox" checked={this.props.resident.attending} onChange={this.handleAttendClick} />
        </label>
        <label>Late
          <input type="checkbox" checked={this.props.resident.late} onChange={this.handleLateClick} />
        </label>
        <label>Veg
          <input type="checkbox" checked={this.props.resident.vegetarian} onChange={this.handleVegClick} />
        </label>
        <button onClick={this.handleGuestAdd} >Add Guest</button>
        {this.props.resident.guests > 0 ? <button onClick={this.handleGuestRemove} >Remove Guest</button> : null}
      </div>
    )
  }
}

export default AttendeeComponent
