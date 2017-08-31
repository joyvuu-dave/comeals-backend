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
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals?community_id=${window.community_id}`,
          color: "var(--livid)"
        },
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/bills?community_id=${window.community_id}`,
          color: "var(--almost-black)"
        },
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/rotations?community_id=${window.community_id}`
        }
      ],
      contentHeight: "auto",
      eventRender: function(event, eventElement) {
        const startString = moment(event.start).format();
        const todayString = moment().format("YYYY-MM-DD");

        if (
          moment(startString).isBefore(todayString, "day") &&
          typeof event.url !== "undefined"
        ) {
          eventElement.css("opacity", "0.5");
        }

        eventElement.attr("title", event.description);
      }
    });

    setInterval(() => this.refetch(calendar), 60000);

    // Fix for mobile flex bug
    document.getElementById("main").remove();
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
