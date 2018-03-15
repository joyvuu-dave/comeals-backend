import React from "react";
import $ from "jquery";
import "fullcalendar";
import "fullcalendar/dist/fullcalendar.css";
import Cookie from "js-cookie";
import moment from "moment";

const styles = {
  main: {
    display: "flex",
    justifyContent: "space-between"
  },
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

class ResidentsCalendar extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      displayEventEnd: true,
      eventSources: [
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/meals?community_id=${window.community_id}`,
          color: "#6699cc" // livid
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/bills?community_id=${window.community_id}`,
          color: "#444" // almost-black
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/rotations?community_id=${window.community_id}`
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/events?community_id=${window.community_id}`
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/guest-room-reservations?community_id=${window.community_id}`
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/common-house-reservations?community_id=${window.community_id}`
        },
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/communities/${window.community_id}/birthdays?community_id=${window.community_id}`
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

  openWiki() {
    window.open("https://wiki.swansway.com/", "_blank");
  }

  refetch(calendar) {
    $(calendar).fullCalendar("refetchEvents");
  }

  logoutText() {
    const token = Cookie.get("token");
    if(typeof token  === "undefined") {
      return "login";
    } else {
      return `logout ${window.comeals.name}`;
    }
  }

  render() {
    return (
      <div className="offwhite">
        <header className="header flex right">
          <button onClick={this.openWiki} className="button-link text-secondary">
            wiki
          </button>
          <button onClick={this.logout} className="button-link text-secondary">
            {this.logoutText()}
          </button>
        </header>
        <div style={styles.main}>
          <div style={styles.sideBar}>
            <h3 className="mar-sm">Reserve</h3>
            <button className="mar-sm">Guest Room</button>
            <button className="mar-sm">Common House</button>
            <hr></hr>
            <h3 className="mar-sm">Calendars</h3>
            <button className="button-info mar-sm">ALL</button>
            <hr></hr>
            <button className="button-info mar-sm disabled">Meals</button>
            <button onClick={this.openGuestRoom} className="button-info mar-sm disabled">Guest Room</button>
            <button className="button-info mar-sm disabled">Common House</button>
            <hr></hr>
            <button className="button-info mar-sm disabled">Events</button>
            <button className="button-info mar-sm disabled">Birthdays</button>
            <hr></hr>
            <h3 className="mar-sm">Add</h3>
            <button className="mar-sm button-secondary">Event</button>
          </div>
          <div ref="calendar" className="calendar" />
        </div>
      </div>
    );
  }
}

export default ResidentsCalendar;
