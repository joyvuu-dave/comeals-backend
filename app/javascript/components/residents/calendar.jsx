import React from "react";
import $ from "jquery";
import "fullcalendar";
import "fullcalendar/dist/fullcalendar.css";
import Cookie from "js-cookie";
import moment from "moment";

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
      ],
      contentHeight: "auto",
      eventRender: function(event, eventElement) {
        const startString = moment(event.start).format();
        const todayString = moment().format("YYYY-MM-DD");

        if (moment(startString).isBefore(todayString, "day")) {
          eventElement.css("opacity", "0.5");
        }
      }
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
        <header className="header flex right">
          <button onClick={this.logout} className="button-link">
            logout
          </button>
        </header>
        <div ref="calendar" className="calendar" />
      </div>
    );
  }
}

export default ResidentsCalendar;
