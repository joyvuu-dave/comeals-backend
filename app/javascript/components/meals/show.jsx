import React from 'react'
import AttendeeForm from './attendee_form'
import CookForm from './cook_form'

class MealsShow extends React.Component {
  render() {
    return(
      <div>
        <CookForm />
        <br />
        <AttendeeForm />
      </div>
    )
  }
}

export default MealsShow
