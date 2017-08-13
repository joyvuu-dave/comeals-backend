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
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals`,
          color: "var(--livid)"
        },
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/bills`,
          color: "var(--almost-black)"
        }
      ]
    });

    setInterval(() => this.refetch(calendar), 60000);
  }

  logout() {
    Cookie.remove("token", { domain: `.comeals${window.topLevel}` });
    window.location.href = "/";
  }

  refetch(calendar) {
    $(calendar).fullCalendar("refetchEvents");
  }

  render() {
    return (
      <div className="offwhite">
        <button onClick={this.logout}>Logout</button>
        <br />
        <div ref="calendar" />
      </div>
    );
  }
}

export default ResidentsCalendar;
