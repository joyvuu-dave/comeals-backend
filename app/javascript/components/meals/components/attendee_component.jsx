import React from 'react'
import axios from 'axios'

class AttendeeComponent extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      name: 'loading...',
      attending: false,
      late: false,
      vegetarian: false,
      guests: 0,
      meal_id: -1,
      resident_id: -1
    }

    this.handleAttendClick = this.handleAttendClick.bind(this)
    this.handleLateClick = this.handleLateClick.bind(this)
    this.handleVegClick = this.handleVegClick.bind(this)
    this.handleGuestAdd = this.handleGuestAdd.bind(this)
    this.handleGuestRemove = this.handleGuestRemove.bind(this)
  }

  componentDidMount() {
    this.setState({
      name: this.props.resident.name,
      attending: this.props.resident.attending,
      late: this.props.resident.late,
      vegetarian: this.props.resident.vegetarian,
      guests: this.props.resident.guests,
      meal_id: this.props.resident.meal_id,
      resident_id: this.props.resident.resident_id
    })
  }

  createAttendance() {
    axios.post(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}`)
    .then(function (response) {
      if(response.status === 200) {
        console.log('Post - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  deleteAttendance() {
    axios.delete(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}`)
    .then(function (response) {
      if(response.status === 200) {
        console.log('Delete - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  handleAttendClick(event) {
    const checked = event.target.checked
    this.setState({ attending: checked })

    if(checked) {
      this.createAttendance()
    } else {
      this.deleteAttendance()
    }
  }

  handleLateClick(event) {
    this.setState({ late: event.target.checked })

    axios.patch(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}`, {late: event.target.checked})
    .then(function (response) {
      if(response.status === 200) {
        console.log('Late click - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  handleVegClick(event) {
    this.setState({ vegetarian: event.target.checked })

    axios.patch(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}`, {vegetarian: event.target.checked})
    .then(function (response) {
      if(response.status === 200) {
        console.log('Veg click - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  handleGuestAdd() {
    this.setState({ guests: this.state.guests + 1 })

    axios.post(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}/guests`)
    .then(function (response) {
      if(response.status === 200) {
        console.log('Guests Post - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  handleGuestRemove() {
    this.setState({ guests: this.state.guests - 1 })

    axios.delete(`http://api.comeals.dev/api/v1/meals/${this.state.meal_id}/residents/${this.state.resident_id}/guests`)
    .then(function (response) {
      if(response.status === 200) {
        console.log('Guests Delete - Success!', response.data)
      }
    })
    .catch(function (error) {
      if (error.response) {
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx
        const data = error.response.data
        const status = error.response.status
        const headers = error.response.headers

        window.alert(data.message)
      } else if (error.request) {
        // The request was made but no response was received
        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
        // http.ClientRequest in node.js
        const request = error.request
      } else {
        // Something happened in setting up the request that triggered an Error
        const message = error.message
      }
      const config = error.config
    })
  }

  render() {
    return(
      <div>
        <label>{this.state.name}
          <input type="checkbox" checked={this.state.attending} onChange={this.handleAttendClick} />
        </label>
        <label>Late
          <input type="checkbox" checked={this.state.late} onChange={this.handleLateClick} />
        </label>
        <label>Veg
          <input type="checkbox" checked={this.state.vegetarian} onChange={this.handleVegClick} />
        </label>
        <button onClick={this.handleGuestAdd} >Add Guest</button>{this.state.guests}
        <button onClick={this.handleGuestRemove} disabled={this.state.guests === 0}>Remove Guest</button>
      </div>
    )
  }
}

export default AttendeeComponent
