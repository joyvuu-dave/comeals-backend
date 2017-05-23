import React from 'react'
import $ from 'jquery'
import 'fullcalendar'
import 'fullcalendar/dist/fullcalendar.css'

class StaticIndex extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs
    $(calendar).fullCalendar()
  }

  render() {
    return <div ref="calendar">
             StaticIndex Component Foo
           </div>
  }
}

export default StaticIndex
