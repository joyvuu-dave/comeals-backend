import React from "react";
import $ from "jquery";
import "fullcalendar";
import "fullcalendar/dist/fullcalendar.css";
import Cookie from "js-cookie";

const styles = {
  main: {
    width: "95vw",
    marginLeft: "auto",
    marginRight: "auto",
    marginTop: "1rem",
    marginBottom: "1rem"
  }
};

class ResidentsCalendar extends React.Component {
  componentDidMount() {
    const { calendar } = this.refs;
    $(calendar).fullCalendar({
      eventSources: [
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals`,
          color: "var(--livid)"
        },
        {
          url: `${window.host}api.comeals${window.topLevel}/api/v1/bills`,
          color: "var(--almost-black)"
        }
      ],
      contentHeight: 600
    });

    setInterval(() => this.refetch(calendar), 60000);
  }

  logout() {
    Cookie.remove("token", { domain: `.comeals${window.topLevel}` });
    window.location.href = "/";
  }

  refetch(calendar) {
    $(calendar).fullCalendar("refetchEvents");
  }

  render() {
    return (
      <div className="offwhite">
        <header className="header flex right">
          <button onClick={this.logout} className="button-link">
            Logout
          </button>
        </header>
        <div ref="calendar" style={styles.main} />
      </div>
    );
  }
}

export default ResidentsCalendar;
