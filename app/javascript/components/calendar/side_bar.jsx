import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";
import { getCalendarInfo } from "../../helpers/helpers";
import Cookie from "js-cookie";

const styles = {
  sideBar: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start"
  }
};

const SideBar = inject("store")(
  withRouter(
    observer(
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

        componentDidMount() {
          this.setInfo();
        }

        componentDidUpdate() {
          this.setInfo();
        }

        setInfo() {
          if (this.props.store.router) {
            var pathNameArray = this.props.store.router.location.pathname.split(
              "/"
            );
            var pathName = pathNameArray[pathNameArray.length - 1];
            if (pathName === "calendar") {
              pathName = "all";
            }

            var calendarInfo = getCalendarInfo(
              Cookie.get("community_id"),
              pathName
            );

            store.setCalendarInfo(
              calendarInfo.displayName,
              calendarInfo.eventSources
            );
          }
        }

        openNewGuestRoomReservation() {
          // window.open(
          //   `${this.state.host}${this.state.slug}.comeals${
          //     this.state.topLevel
          //   }/guest-room-reservations/new`
          // );
          store.openModal("guestRoomNew");
        }

        openNewCommonHouseReservation() {
          // window.open(
          //   `${this.state.host}${this.state.slug}.comeals${
          //     this.state.topLevel
          //   }/common-house-reservations/new`
          // );

          store.openModal("commonHouseNew");
        }

        openNewEvent() {
          // window.open(
          //   `${this.state.host}${this.state.slug}.comeals${
          //     this.state.topLevel
          //   }/events/new`
          // );

          store.openModal("eventNew");
        }

        openAllCalendars() {
          this.props.store.router.push("/calendar");
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
    )
  )
);

export default SideBar;
