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

class ResidentsGuestRoomCalendar extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      displayEventEnd: true,
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

  openWiki() {
    window.open("https://wiki.swansway.com/", "_blank");
  }

  openNewGuestRoomReservation() {
    window.open(`${window.host}patches.comeals${window.topLevel}/guest-room-reservations/new`)
  }

  openNewCommonHouseReservation() {
    window.open(`${window.host}patches.comeals${window.topLevel}/common-house-reservations/new`)
  }

  openNewEvent() {
    window.open(`${window.host}patches.comeals${window.topLevel}/events/new`)
  }

  openAllCalendars() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar`)
  }

  openMealCalendar() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar/meals`)
  }

  openGuestRoomCalendar() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar/guest-room`)
  }

  openCommonHouseCalendar() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar/common-house`)
  }

  openEventsCalendar() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar/events`)
  }

  openBirthdaysCalendar() {
    window.open(`${window.host}patches.comeals${window.topLevel}/calendar/birthdays`)
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
            <button onClick={this.openNewGuestRoomReservation} className="mar-sm">Guest Room</button>
            <button onClick={this.openNewCommonHouseReservation} className="mar-sm">Common House</button>
            <hr></hr>
            <h3 className="mar-sm">Calendars</h3>
            <button onClick={this.openAllCalendars} className="button-info mar-sm">ALL</button>
            <hr></hr>
            <button onClick={this.openMealCalendar} className="button-info mar-sm">Meals</button>
            <button onClick={this.openGuestRoomCalendar} className="button-info mar-sm">Guest Room</button>
            <button onClick={this.openCommonHouseCalendar} className="button-info mar-sm">Common House</button>
            <hr></hr>
            <button onClick={this.openEventsCalendar} className="button-info mar-sm">Events</button>
            <button onClick={this.openBirthdaysCalendar} className="button-info mar-sm">Birthdays</button>
            <hr></hr>
            <h3 className="mar-sm">Add</h3>
            <button onClick={this.openNewEvent} className="mar-sm button-secondary">Event</button>
          </div>
          <div ref="calendar" className="calendar" />
        </div>
      </div>
    );
  }
}

export default ResidentsGuestRoomCalendar;
