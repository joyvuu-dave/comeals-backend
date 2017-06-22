import React from 'react'
import axios from 'axios'
import AttendeeComponent from './attendee_component'

class AttendeeForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      attendees: []
    }
  }

  componentDidMount() {
    const self = this
    axios.get("http://api.comeals.dev/api/v1/meals/1/attendees")
    .then(function(response) {
      if(response.status === 200) {
        self.setState({
          attendees: response.data
        })
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
        <h3>Attendee Form</h3>
        {this.state.attendees.map((resident) =>
          <AttendeeComponent key={resident.resident_id} resident={resident} />
        )}
      </div>
    )
  }
}

export default AttendeeForm
