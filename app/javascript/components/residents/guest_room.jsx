import React, { Component } from "react";
import $ from "jquery";
import "fullcalendar";

import Cookie from "js-cookie";
import moment from "moment";

class ResidentsGuestRoom extends Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      eventSources: [
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/guest-room-reservations?community_id=${window.community_id}`
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

  openProfile() {
    window.open("/profile", "_blank");
  }

  refetch(calendar) {
    $(calendar).fullCalendar("refetchEvents");
  }

  render() {
    return (
      <div className="offwhite">
        <header className="header flex right">
          <button onClick={this.openProfile} className="button-link">
            Profile
          </button>
          <button onClick={this.logout} className="button-link">
            logout
          </button>
        </header>
        <div ref="calendar" className="calendar" />
      </div>
    );
  }
}

export default ResidentsGuestRoom;
