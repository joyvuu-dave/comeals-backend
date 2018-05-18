import React, { Component } from "react";
import { inject } from "mobx-react";

const styles = {
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

const SideBar = inject("store")(
  class SideBar extends Component {
    openNewGuestRoomReservation() {
      this.props.store.openModal("guestRoomNew");
    }

    openNewCommonHouseReservation() {
      this.props.store.openModal("commonHouseNew");
    }

    openNewEvent() {
      this.props.store.openModal("eventNew");
    }

    openAllCalendars() {
      this.props.store.router.push("/calendar/all");
    }

    openMealCalendar() {
      this.props.store.router.push("/calendar/meals");
    }

    openGuestRoomCalendar() {
      this.props.store.router.push("/calendar/guest-room");
    }

    openCommonHouseCalendar() {
      this.props.store.router.push("/calendar/common-house");
    }

    openEventsCalendar() {
      this.props.store.router.push("/calendar/events");
    }

    openBirthdaysCalendar() {
      this.props.store.router.push("/calendar/birthdays");
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
