import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router-dom";
import $ from "jquery";
import "fullcalendar";
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

BigCalendar.setLocalizer(BigCalendar.momentLocalizer(moment));

const styles = {
  main: {
    display: "flex",
    justifyContent: "space-between"
  }
};

Modal.setAppElement("#main");
const Calendar = inject("store")(
  withRouter(
    observer(
      class Calendar extends Component {
        constructor(props) {
          super(props);

          console.log("calendar's constructor ran!");

          this.handleCloseModal = this.handleCloseModal.bind(this);
        }

        componentDidMount() {
          console.log("calendar mounted!");
          //this.updateEventSources();
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
                return <GuestRoomReservationsNew />;
                break;

              case "common-house-reservations":
                return <CommonHouseReservationsNew />;
                break;

              case "events":
                return <EventsNew />;
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
                  />
                );
                break;

              case "common-house-reservations":
                return (
                  <CommonHouseReservationsEdit
                    eventId={this.props.match.params.id}
                  />
                );
                break;

              case "events":
                return <EventsEdit eventId={this.props.match.params.id} />;
                break;

              default:
                null;
            }
          }

          // SHOW RESOURCE
          if (this.props.match.params.view === "show") {
            switch (this.props.match.params.modal) {
              case "rotations":
                return <RotationsShow id={this.props.match.params.id} />;
                break;

              default:
                null;
            }
          }
        }

        handleCloseModal() {
          //this.props.store.closeModal();
          this.props.history.push(
            `/calendar/${this.props.match.params.type}/${
              this.props.match.params.date
            }`
          );
        }

        updateEventSources() {
          // var pathNameArray = this.props.location.pathname.split("/");
          // var calendarInfo = getCalendarInfo(
          //   Cookie.get("community_id"),
          //   pathNameArray[2]
          // );
          // this.props.store.setCalendarInfo(
          //   calendarInfo.displayName,
          //   calendarInfo.eventSources
          // );
          // const { calendar } = this.refs;
          // var events = this.props.store.calendarEvents;
          // var self = this;
          // $(calendar).fullCalendar("destroy");
          // $(calendar).fullCalendar({
          //   displayEventEnd: true,
          //   events: events,
          //   defaultDate: moment(window.location.pathname.split("/")[3]),
          //   contentHeight: "auto",
          //   eventRender: function(event, eventElement) {
          //     const startString = moment(event.start).format();
          //     const todayString = moment().format("YYYY-MM-DD");
          //     if (
          //       moment(startString).isBefore(todayString, "day") &&
          //       typeof event.url !== "undefined"
          //     ) {
          //       eventElement.css("opacity", "0.5");
          //     }
          //     eventElement.attr("title", event.description);
          //   },
          //   eventClick: function(event) {
          //     if (event.url) {
          //       self.props.history.push(event.url);
          //       return false;
          //     }
          //   }
          // });
          // // Handle Today Click
          // $(".fc-today-button").click(function(event) {
          //   event.preventDefault();
          //   event.stopPropagation();
          //   // Get Date for Prev Month
          //   var myCurrentDate = $(calendar).fullCalendar("getDate");
          //   myCurrentDate = moment(myCurrentDate).format("YYYY-MM-DD");
          //   // Get Current Calendar Type
          //   const calType = self.props.location.pathname.split("/")[2];
          //   // Update Location
          //   self.props.history.push(`/calendar/${calType}/${myCurrentDate}`);
          //   return false;
          // });
          // // Handle Prev Click
          // $(".fc-prev-button").click(function(event) {
          //   event.preventDefault();
          //   event.stopPropagation();
          //   // Get Date for Prev Month
          //   var myPrevDate = $(calendar).fullCalendar("getDate");
          //   myPrevDate = moment(myPrevDate).format("YYYY-MM-DD");
          //   // Get Current Calendar Type
          //   const calType = self.props.location.pathname.split("/")[2];
          //   // Update Location
          //   self.props.history.push(`/calendar/${calType}/${myPrevDate}`);
          //   return false;
          // });
          // // Handle Next Click
          // $(".fc-next-button").click(function(event) {
          //   event.preventDefault();
          //   event.stopPropagation();
          //   // Get Date for Next Month
          //   var myNextDate = $(calendar).fullCalendar("getDate");
          //   myNextDate = moment(myNextDate).format("YYYY-MM-DD");
          //   // Get Current Calendar Type
          //   const calType = self.props.location.pathname.split("/")[2];
          //   // Update Location
          //   self.props.history.push(`/calendar/${calType}/${myNextDate}`);
          //   return false;
          // });
          // // Refetch Data Every 5 Minutes
          // setInterval(() => this.refetch(calendar), 300000);
        }

        openWiki() {
          window.open("https://wiki.swansway.com/", "noopener");
        }

        refetch(calendar) {
          $(calendar).fullCalendar("refetchEvents");
        }

        render() {
          console.log("calendar rendered!");

          return (
            <div className="offwhite">
              <header className="header flex space-between">
                <h5 className="pad-xs">{moment().format("ddd MMM Do")}</h5>
                <span>
                  <button
                    onClick={this.openWiki}
                    className="button-link text-secondary"
                  >
                    wiki
                  </button>
                  <button
                    onClick={this.props.store.logout}
                    className="button-link text-secondary"
                  >
                    {`logout ${Cookie.get("username")}`}
                  </button>
                </span>
              </header>
              <h2 className="flex center">
                <u>{this.props.store.calendarName}</u>
              </h2>
              <div style={styles.main} className="responsive-calendar">
                <SideBar
                  match={this.props.match}
                  history={this.props.history}
                  location={this.props.location}
                />
                <div>
                  <BigCalendar
                    defaultDate={new Date()}
                    defaultView="month"
                    events={this.props.store.calendarEvents.toJS()}
                    style={{ height: "100vh", width: "85vw", minHeight: "90%" }}
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
      }
    )
  )
);

export default Calendar;
