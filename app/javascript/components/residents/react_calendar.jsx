import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";
import BigCalendar from "react-big-calendar";
import moment from "moment";

BigCalendar.setLocalizer(BigCalendar.momentLocalizer(moment));

class ResidentsReactCalendar extends Component {
  constructor(props) {
    super(props);

    this.state = {
      events: [
        {
          start: new Date(),
          end: new Date(moment().add(1, "days")),
          title: "Some title"
        }
      ]
    };
  }

  render() {
    return (
      <BigCalendar
        defaultDate={new Date()}
        defaultView="month"
        events={this.state.events}
        style={{ height: "100vh" }}
      />
    );
  }
}

export default ResidentsReactCalendar;
