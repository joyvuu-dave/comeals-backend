import React from "react";
import $ from "jquery";
import "fullcalendar";
import "fullcalendar/dist/fullcalendar.css";
import Cookie from "js-cookie";

class ResidentsCalendar extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      eventSources: [
        { url: "http://api.comeals.dev/api/v1/meals", color: "#729f98" },
        { url: "http://api.comeals.dev/api/v1/bills", color: "#aa863a" }
      ]
    });
  }

  logout() {
    Cookie.remove("token", { domain: ".comeals.dev" });
    window.location.href = "/";
  }

  render() {
    return (
      <div>
        <button onClick={this.logout}>Logout</button>
        <br />
        <div ref="calendar" />
      </div>
    );
  }
}

export default ResidentsCalendar;
