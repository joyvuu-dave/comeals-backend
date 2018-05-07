import React, { Component } from "react";

const styles = {
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

class SideBar extends Component {
  constructor(props) {
    super(props);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`,
      slug: window.location.hostname.split(".")[0]
    };
  }

  openNewGuestRoomReservation() {
    window.open(
      `${this.state.host}${this.state.slug}.comeals${
        this.state.topLevel
      }/guest-room-reservations/new`
    );
  }

  openNewCommonHouseReservation() {
    window.open(
      `${this.state.host}${this.state.slug}.comeals${
        this.state.topLevel
      }/common-house-reservations/new`
    );
  }

  openNewEvent() {
    window.open(
      `${this.state.host}${this.state.slug}.comeals${
        this.state.topLevel
      }/events/new`
    );
  }

  openAllCalendars() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar`;
  }

  openMealCalendar() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar/meals`;
  }

  openGuestRoomCalendar() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar/guest-room`;
  }

  openCommonHouseCalendar() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar/common-house`;
  }

  openEventsCalendar() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar/events`;
  }

  openBirthdaysCalendar() {
    window.location.href = `${this.state.host}${this.state.slug}.comeals${
      this.state.topLevel
    }/calendar/birthdays`;
  }

  render() {
    return (
      <div style={styles.sideBar}>
        <h3 className="mar-sm">Reserve</h3>
        <button
          onClick={this.openNewGuestRoomReservation.bind(this)}
          className="mar-sm"
        >
          Guest Room
        </button>
        <button
          onClick={this.openNewCommonHouseReservation.bind(this)}
          className="mar-sm"
        >
          Common House
        </button>
        <hr />
        <h3 className="mar-sm">Calendars</h3>
        <button
          onClick={this.openAllCalendars.bind(this)}
          className="button-info mar-sm"
        >
          ALL
        </button>
        <hr />
        <button
          onClick={this.openMealCalendar.bind(this)}
          className="button-info mar-sm"
        >
          Meals
        </button>
        <button
          onClick={this.openGuestRoomCalendar.bind(this)}
          className="button-info mar-sm"
        >
          Guest Room
        </button>
        <button
          onClick={this.openCommonHouseCalendar.bind(this)}
          className="button-info mar-sm"
        >
          Common House
        </button>
        <hr />
        <button
          onClick={this.openEventsCalendar.bind(this)}
          className="button-info mar-sm"
        >
          Events
        </button>
        <button
          onClick={this.openBirthdaysCalendar.bind(this)}
          className="button-info mar-sm"
        >
          Birthdays
        </button>
        <hr />
        <h3 className="mar-sm">Add</h3>
        <button
          onClick={this.openNewEvent.bind(this)}
          className="mar-sm button-secondary"
        >
          Event
        </button>
      </div>
    );
  }
}

export default SideBar;
