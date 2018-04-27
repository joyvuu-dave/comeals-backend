import React, { Component } from "react";

const styles = {
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

class SideBar extends Component {
  openNewGuestRoomReservation() {
    window.open(
      `${window.host}${window.slug}.comeals${
        window.topLevel
      }/guest-room-reservations/new`
    );
  }

  openNewCommonHouseReservation() {
    window.open(
      `${window.host}${window.slug}.comeals${
        window.topLevel
      }/common-house-reservations/new`
    );
  }

  openNewEvent() {
    window.open(
      `${window.host}${window.slug}.comeals${window.topLevel}/events/new`
    );
  }

  openAllCalendars() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar`;
  }

  openMealCalendar() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar/meals`;
  }

  openGuestRoomCalendar() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar/guest-room`;
  }

  openCommonHouseCalendar() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar/common-house`;
  }

  openEventsCalendar() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar/events`;
  }

  openBirthdaysCalendar() {
    window.location.href = `${window.host}${window.slug}.comeals${
      window.topLevel
    }/calendar/birthdays`;
  }

  render() {
    return (
      <div style={styles.sideBar}>
        <h3 className="mar-sm">Reserve</h3>
        <button onClick={this.openNewGuestRoomReservation} className="mar-sm">
          Guest Room
        </button>
        <button onClick={this.openNewCommonHouseReservation} className="mar-sm">
          Common House
        </button>
        <hr />
        <h3 className="mar-sm">Calendars</h3>
        <button onClick={this.openAllCalendars} className="button-info mar-sm">
          ALL
        </button>
        <hr />
        <button onClick={this.openMealCalendar} className="button-info mar-sm">
          Meals
        </button>
        <button
          onClick={this.openGuestRoomCalendar}
          className="button-info mar-sm"
        >
          Guest Room
        </button>
        <button
          onClick={this.openCommonHouseCalendar}
          className="button-info mar-sm"
        >
          Common House
        </button>
        <hr />
        <button
          onClick={this.openEventsCalendar}
          className="button-info mar-sm"
        >
          Events
        </button>
        <button
          onClick={this.openBirthdaysCalendar}
          className="button-info mar-sm"
        >
          Birthdays
        </button>
        <hr />
        <h3 className="mar-sm">Add</h3>
        <button onClick={this.openNewEvent} className="mar-sm button-secondary">
          Event
        </button>
      </div>
    );
  }
}

export default SideBar;
