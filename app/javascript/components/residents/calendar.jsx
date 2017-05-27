import React from 'react'
import $ from 'jquery'
import 'fullcalendar'
import 'fullcalendar/dist/fullcalendar.css'
import Cookie from 'js-cookie'

class ResidentsCalendar extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs
    $(calendar).fullCalendar()
  }

  logout() {
    Cookie.remove('token', { domain: '.comeals.dev' })
    window.location.href = '/'
  }

  render() {
    return (<div>
              <button onClick={this.logout}>Logout</button>
              <br />
              <div ref="calendar"></div>
            </div>
    )
  }
}

export default ResidentsCalendar
