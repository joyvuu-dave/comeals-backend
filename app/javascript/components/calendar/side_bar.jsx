import React, { Component } from "react";
import { inject } from "mobx-react";
import moment from "moment";

const styles = {
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

const SideBar = inject("store")(
  class SideBar extends Component {
    getNavDate() {
      return this.props.location.pathname.split("/")[3];
    }

    openNewGuestRoomReservation() {
      this.props.history.push(
        `${this.props.location.pathname}guest-room-reservations/new`
      );
    }

    openNewCommonHouseReservation() {
      this.props.history.push(
        `${this.props.location.pathname}common-house-reservations/new`
      );
    }

    openNewEvent() {
      this.props.history.push(`${this.props.location.pathname}events/new`);
    }

    openAllCalendars() {
      this.props.history.push(
        `/calendar/all/${moment(this.getNavDate()).format("YYYY-MM-DD")}`
      );
    }

    openMealCalendar() {
      this.props.history.push(
        `/calendar/meals/${moment(this.getNavDate()).format("YYYY-MM-DD")}`
      );
    }

    openGuestRoomCalendar() {
      this.props.history.push(
        `/calendar/guest-room/${moment(this.getNavDate()).format("YYYY-MM-DD")}`
      );
    }

    openCommonHouseCalendar() {
      this.props.history.push(
        `/calendar/common-house/${moment(this.getNavDate()).format(
          "YYYY-MM-DD"
        )}`
      );
    }

    openEventsCalendar() {
      this.props.history.push(
        `/calendar/events/${moment(this.getNavDate()).format("YYYY-MM-DD")}`
      );
    }

    openBirthdaysCalendar() {
      this.props.history.push(
        `/calendar/birthdays/${moment(this.getNavDate()).format("YYYY-MM-DD")}`
      );
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
);

export default SideBar;
