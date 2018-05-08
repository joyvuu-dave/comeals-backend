import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";
import $ from "jquery";
import "fullcalendar";
import SideBar from "./side_bar";

import Cookie from "js-cookie";
import moment from "moment";

import Modal from "react-modal";
import GuestRoomReservationsNew from "../guest_room_reservations/new";
import CommonHouseReservationsNew from "../common_house_reservations/new";
import EventsNew from "../events/new";

const styles = {
  main: {
    display: "flex",
    justifyContent: "space-between"
  }
};

Modal.setAppElement("#site");
const Calendar = inject("store")(
  withRouter(
    observer(
      class Calendar extends Component {
        constructor(props) {
          super(props);

          const node = document.getElementById("site-data");
          const data = JSON.parse(node.getAttribute("data"));
          this.state = {
            hosts: data.hosts,
            residents: data.residents
          };
          this.handleCloseModal = this.handleCloseModal.bind(this);
        }

        renderModal() {
          if (store.modalActive === false) {
            return null;
          }

          switch (store.modalName) {
            case "guestRoomNew":
              return <GuestRoomReservationsNew hosts={this.state.hosts} />;
              break;

            case "commonHouseNew":
              return (
                <CommonHouseReservationsNew residents={this.state.residents} />
              );
              break;

            case "eventNew":
              return <EventsNew />;
              break;

            default:
              return null;
          }
        }

        handleCloseModal() {
          store.closeModal();
        }

        updateEventSources() {
          const { calendar } = this.refs;
          var eventSources = store.eventSources;

          $(calendar).fullCalendar("destroy");
          $(calendar).fullCalendar({
            displayEventEnd: true,
            eventSources: eventSources,
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
        }

        componentDidMount() {
          this.updateEventSources();

          // Fix for mobile flex bug
          document.getElementById("main").remove();
        }

        componentDidUpdate() {
          if (!store.modalIsChanging) {
            this.updateEventSources();
          }
        }

        logout() {
          var topLevel = window.location.hostname.split(".");
          topLevel = topLevel[topLevel.length - 1];

          Cookie.remove("token", { domain: `.comeals.${topLevel}` });
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
          if (typeof token === "undefined") {
            return "login";
          } else {
            return `logout ${store.userName}`;
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
                <u>{store.calendarName}</u>
              </h2>
              <div style={styles.main} className="responsive-calendar">
                <SideBar />
                <div ref="calendar" className="calendar" />
              </div>
              <Modal
                isOpen={store.modalActive}
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
