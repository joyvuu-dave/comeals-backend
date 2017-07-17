import React from 'react'
import ReactDOM from 'react-dom'

import ResidentsCalendar from '../../components/residents/calendar'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <ResidentsCalendar />,
    document.getElementById("root")
  )
})
