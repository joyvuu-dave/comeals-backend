import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router-dom";
import SideBar from "./side_bar";

import { getCalendarInfo } from "../../helpers/helpers";
import Cookie from "js-cookie";
import moment from "moment";

import Modal from "react-modal";
import GuestRoomReservationsNew from "../guest_room_reservations/new";
import CommonHouseReservationsNew from "../common_house_reservations/new";
import EventsNew from "../events/new";
import GuestRoomReservationsEdit from "../guest_room_reservations/edit";
import CommonHouseReservationsEdit from "../common_house_reservations/edit";
import EventsEdit from "../events/edit";
import RotationsShow from "../rotations/show";

import WebcalLinks from "./webcal_links";
import BigCalendar from "react-big-calendar";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faChevronLeft } from "@fortawesome/free-solid-svg-icons";
import { faChevronRight } from "@fortawesome/free-solid-svg-icons";

BigCalendar.setLocalizer(BigCalendar.momentLocalizer(moment));

const styles = {
  main: {
    display: "flex",
    justifyContent: "space-between"
  },
  chevron: {
    backgroundColor: "#444",
    border: "none",
    opacity: "0.75"
  }
};

class MyToolbar extends Component {
  render() {
    return (
      <div style={styles.main}>
        <h2>{moment(this.props.date).format("MMMM YYYY")}</h2>
        <span>
          <button
            className="mar-sm"
            onClick={this.navigate.bind(null, "TODAY")}
          >
            today
          </button>
          <button
            style={styles.chevron}
            onClick={this.navigate.bind(null, "PREVIOUS")}
          >
            <FontAwesomeIcon icon={faChevronLeft} />
          </button>
          <button
            style={styles.chevron}
            onClick={this.navigate.bind(null, "NEXT")}
          >
            <FontAwesomeIcon icon={faChevronRight} />
          </button>
        </span>
      </div>
    );
  }

  navigate = action => {
    this.props.onNavigate(action);
  };
}

let components = {
  toolbar: MyToolbar
};

Modal.setAppElement("#main");
const Calendar = inject("store")(
  withRouter(
    observer(
      class Calendar extends Component {
        constructor(props) {
          super(props);

          this.handleCloseModal = this.handleCloseModal.bind(this);

          this.handleNavigate = this.handleNavigate.bind(this);
          this.handleSelectEvent = this.handleSelectEvent.bind(this);
          this.filterEvents = this.filterEvents.bind(this);
          this.formatEvent = this.formatEvent.bind(this);
        }

        componentDidMount() {
          this.props.store.goToMonth(this.props.match.params.date);
        }

        componentDidUpdate(prevProps) {
          console.log("calendar updated!");

          if (
            prevProps.match.params.type !== this.props.match.params.type ||
            prevProps.match.params.date !== this.props.match.params.date
          ) {
            console.log("different calendar!");
            this.props.store.goToMonth(this.props.match.params.date);
          }
        }

        renderModal() {
          if (typeof this.props.match.params.modal === "undefined") {
            return null;
          }

          // NEW RESOURCE
          if (this.props.match.params.view === "new") {
            switch (this.props.match.params.modal) {
              case "guest-room-reservations":
                return (
                  <GuestRoomReservationsNew
                    handleCloseModal={this.handleCloseModal}
                    match={this.props.match}
                  />
                );
                break;

              case "common-house-reservations":
                return (
                  <CommonHouseReservationsNew
                    handleCloseModal={this.handleCloseModal}
                    match={this.props.match}
                  />
                );
                break;

              case "events":
                return (
                  <EventsNew
                    handleCloseModal={this.handleCloseModal}
                    match={this.props.match}
                  />
                );
                break;

              default:
                return null;
            }
          }

          // EDIT RESOURCE
          if (this.props.match.params.view === "edit") {
            switch (this.props.match.params.modal) {
              case "guest-room-reservations":
                return (
                  <GuestRoomReservationsEdit
                    eventId={this.props.match.params.id}
                    handleCloseModal={this.handleCloseModal}
                  />
                );
                break;

              case "common-house-reservations":
                return (
                  <CommonHouseReservationsEdit
                    eventId={this.props.match.params.id}
                    handleCloseModal={this.handleCloseModal}
                  />
                );
                break;

              case "events":
                return (
                  <EventsEdit
                    eventId={this.props.match.params.id}
                    handleCloseModal={this.handleCloseModal}
                  />
                );
                break;

              default:
                null;
            }
          }

          // SHOW RESOURCE
          if (this.props.match.params.view === "show") {
            switch (this.props.match.params.modal) {
              case "rotations":
                return (
                  <RotationsShow
                    id={this.props.match.params.id}
                    handleCloseModal={this.handleCloseModal}
                  />
                );
                break;

              default:
                null;
            }
          }
        }

        handleCloseModal() {
          this.props.history.push(
            `/calendar/${this.props.match.params.type}/${
              this.props.match.params.date
            }`
          );
        }

        formatEvent(event) {
          var styles = { style: {} };

          const startString = moment(event.start).format();
          const todayString = moment().format("YYYY-MM-DD");

          if (
            moment(startString).isBefore(todayString, "day") &&
            typeof event.url !== "undefined"
          ) {
            styles.style["opacity"] = "0.5";
          }

          styles.style["backgroundColor"] = event.color;
          return styles;
        }

        render() {
          return (
            <div className="offwhite">
              <header className="header flex space-between">
                <h5 className="pad-xs">{moment().format("ddd MMM Do")}</h5>
                {this.props.store.isOnline ? (
                  <span className="online">ONLINE</span>
                ) : (
                  <span className="offline">OFFLINE</span>
                )}
                <span>
                  <button
                    onClick={this.props.store.logout}
                    className="button-link text-secondary"
                  >
                    {`logout ${Cookie.get("username")}`}
                  </button>
                </span>
              </header>
              <h2 className="flex center">
                <u>
                  {this.props.match.params.type.toUpperCase().replace("-", " ")}
                </u>
              </h2>
              <div style={styles.main} className="responsive-calendar">
                <SideBar
                  match={this.props.match}
                  history={this.props.history}
                  location={this.props.location}
                />
                <div style={{ height: 2000 }}>
                  <BigCalendar
                    defaultDate={moment(this.props.match.params.date).toDate()}
                    defaultView="month"
                    eventPropGetter={this.formatEvent.bind(this)}
                    events={this.filterEvents()}
                    className="calendar"
                    onNavigate={this.handleNavigate}
                    onSelectEvent={this.handleSelectEvent}
                    views={["month"]}
                    components={components}
                  />
                  <WebcalLinks />
                </div>
              </div>
              <Modal
                isOpen={typeof this.props.match.params.modal !== "undefined"}
                contentLabel="Event Modal"
                onRequestClose={this.handleCloseModal}
                style={{
                  content: {
                    backgroundColor: "#6699cc"
                  }
                }}
              >
                {this.renderModal()}
              </Modal>
            </div>
          );
        }

        handleNavigate(event) {
          console.log("handleNavigate fired!");
          console.log("event", event);
          this.props.history.push(
            `/calendar/${this.props.match.params.type}/${moment(event).format(
              "YYYY-MM-DD"
            )}`
          );
        }

        handleSelectEvent(event) {
          if (event.url) {
            this.props.history.push(event.url);
            return false;
          }
        }

        filterEvents() {
          var events = this.props.store.calendarEvents.toJS();

          switch (this.props.match.params.type) {
            case "all":
              return events;
            case "meals":
              return events.filter(
                event =>
                  event.type === "Meal" ||
                  event.type === "Rotation" ||
                  event.type === "Bill"
              );
            case "guest-room":
              return events.filter(
                event => event.type === "GuestRoomReservation"
              );
            case "common-house":
              return events.filter(
                event => event.type === "CommonHouseReservation"
              );
            case "events":
              return events.filter(event => event.type === "Event");
            case "birthdays":
              return events.filter(event => event.type === "Birthday");
            default:
              return [];
          }
        }
      }
    )
  )
);

export default Calendar;
