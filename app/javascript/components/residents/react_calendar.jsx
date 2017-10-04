import React from "react";
import BigCalendar from "react-big-calendar";
import "react-big-calendar/lib/css/react-big-calendar.css";
import moment from "moment";
import axios from "axios";
import Cookie from "js-cookie";

BigCalendar.momentLocalizer(moment);

const styles = {
  main: {
    height: "500px"
  }
};

class ResidentsReactCalendar extends React.Component {
  componentDidMount() {}

  logout() {
    Cookie.remove("token", { domain: `.comeals${window.topLevel}` });
    window.location.href = "/";
  }

  render() {
    const myEventsList = [];

    return (
      <div style={styles.main}>
        <BigCalendar events={myEventsList} />
      </div>
    );
  }
}

export default ResidentsReactCalendar;
