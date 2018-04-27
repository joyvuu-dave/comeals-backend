import React, { Component } from "react";
import $ from "jquery";
import "fullcalendar";
import SideBar from "./side_bar";

import Cookie from "js-cookie";
import moment from "moment";

const styles = {
  main: {
    display: "flex",
    justifyContent: "space-between"
  }
};

class ResidentsCommonHouseCalendar extends Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      displayEventEnd: true,
      eventSources: [
        {
          url: `${window.host}api.comeals${
            window.topLevel
          }/api/v1/common-house-reservations?community_id=${
            window.community_id
          }`
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

  refetch(calendar) {
    $(calendar).fullCalendar("refetchEvents");
  }

  logoutText() {
    const token = Cookie.get("token");
    if (typeof token === "undefined") {
      return "login";
    } else {
      return `logout ${window.comeals.name}`;
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
          <button onClick={this.logout} className="button-link text-secondary">
            {this.logoutText()}
          </button>
        </header>
        <h2 className="flex center">
          <u>Comomon House</u>
        </h2>
        <div style={styles.main} className="responsive-calendar">
          <SideBar />
          <div ref="calendar" className="calendar" />
        </div>
      </div>
    );
  }
}

export default ResidentsCommonHouseCalendar;
