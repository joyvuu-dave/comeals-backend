import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";
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
          this.handleCloseModal = this.handleCloseModal.bind(this);
        }

        componentDidMount() {
          this.updateEventSources();
        }

        componentDidUpdate(prevProps) {
          if (
            this.props.location.pathname.split("/")[2] !==
              prevProps.location.pathname.split("/")[2] ||
            this.props.store.modalChangedData
          ) {
            this.updateEventSources();
          }
        }

        renderModal() {
          if (this.props.store.modalActive === false) {
            return null;
          }

          switch (this.props.store.modalName) {
            case "guestRoomNew":
              return <GuestRoomReservationsNew />;
              break;

            case "commonHouseNew":
              return <CommonHouseReservationsNew />;
              break;

            case "eventNew":
              return <EventsNew />;
              break;

            case "guest-room-reservations":
              return (
                <GuestRoomReservationsEdit eventId={this.props.store.modalId} />
              );
              break;

            case "common-house-reservations":
              return (
                <CommonHouseReservationsEdit
                  eventId={this.props.store.modalId}
                />
              );
              break;

            case "events":
              return <EventsEdit eventId={this.props.store.modalId} />;
              break;

            default:
              return null;
          }
        }

        handleCloseModal() {
          this.props.store.closeModal();
        }

        updateEventSources() {
          var pathNameArray = this.props.store.router.location.pathname.split(
            "/"
          );
          var calendarInfo = getCalendarInfo(
            Cookie.get("community_id"),
            pathNameArray[2]
          );

          this.props.store.setCalendarInfo(
            calendarInfo.displayName,
            calendarInfo.eventSources
          );

          const { calendar } = this.refs;
          var eventSources = this.props.store.eventSources;
          var self = this;
          $(calendar).fullCalendar("destroy");
          $(calendar).fullCalendar({
            displayEventEnd: true,
            eventSources: eventSources,
            defaultDate: moment(
              self.props.store.router.location.pathname.split("/")[3]
            ),
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
            },
            eventClick: function(event) {
              if (event.url) {
                if (event.url.split("/")[1] === "meals") {
                  self.props.store.router.push(event.url);
                  return false;
                } else {
                  var temp = event.url.split("#");
                  temp = temp[1];
                  temp = temp.split("/");
                  self.props.store.openModal(
                    temp[0],
                    Number.parseInt(temp[1], 10)
                  );
                  return false;
                }
              }
            }
          });

          // Handle Today Click
          $(".fc-today-button").click(function(event) {
            event.preventDefault();
            event.stopPropagation();

            // Get Date for Prev Month
            var myCurrentDate = $(calendar).fullCalendar("getDate");
            myCurrentDate = moment(myCurrentDate).format("YYYY-MM-DD");

            // Get Current Calendar Type
            const calType = self.props.store.router.location.pathname.split(
              "/"
            )[2];

            // Update Location
            self.props.store.router.push(
              `/calendar/${calType}/${myCurrentDate}`
            );
            return false;
          });

          // Handle Prev Click
          $(".fc-prev-button").click(function(event) {
            event.preventDefault();
            event.stopPropagation();

            // Get Date for Prev Month
            var myPrevDate = $(calendar).fullCalendar("getDate");
            myPrevDate = moment(myPrevDate).format("YYYY-MM-DD");

            // Get Current Calendar Type
            const calType = self.props.store.router.location.pathname.split(
              "/"
            )[2];

            // Update Location
            self.props.store.router.push(`/calendar/${calType}/${myPrevDate}`);
            return false;
          });

          // Handle Next Click
          $(".fc-next-button").click(function(event) {
            event.preventDefault();
            event.stopPropagation();

            // Get Date for Next Month
            var myNextDate = $(calendar).fullCalendar("getDate");
            myNextDate = moment(myNextDate).format("YYYY-MM-DD");

            // Get Current Calendar Type
            const calType = self.props.store.router.location.pathname.split(
              "/"
            )[2];

            // Update Location
            self.props.store.router.push(`/calendar/${calType}/${myNextDate}`);
            return false;
          });

          // Refetch Data Every 5 Minutes
          setInterval(() => this.refetch(calendar), 300000);
        }

        logout() {
          var topLevel = window.location.hostname.split(".");
          topLevel = topLevel[topLevel.length - 1];

          Cookie.remove("token", { domain: `.comeals.${topLevel}` });
          Cookie.remove("community_id", { domain: `.comeals${topLevel}` });
          window.location.href = "/";
        }

        openWiki() {
          window.open("https://wiki.swansway.com/", "noopener");
        }

        refetch(calendar) {
          $(calendar).fullCalendar("refetchEvents");
        }

        logoutText() {
          const token = Cookie.get("token");
          if (typeof token === "undefined") {
            return "login";
          } else {
            return `logout ${this.props.store.userName}`;
          }
        }

        render() {
          return (
            <div className="offwhite">
              <header className="header flex right">
                <button
                  onClick={this.openWiki}
                  className="button-link text-secondary"
                >
                  wiki
                </button>
                <button
                  onClick={this.logout}
                  className="button-link text-secondary"
                >
                  {this.logoutText()}
                </button>
              </header>
              <h2 className="flex center">
                <u>{this.props.store.calendarName}</u>
              </h2>
              <div style={styles.main} className="responsive-calendar">
                <SideBar />
                <div ref="calendar" className="calendar" />
              </div>
              <Modal
                isOpen={this.props.store.modalActive}
                contentLabel="Minimal Modal Example"
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
