import React, { Component } from "react";
import Cookie from "js-cookie";

class WebcalLinks extends Component {
  render() {
    var topLevel = window.location.hostname.split(".")[2];

    return (
      <div className="flex space-between w-100">
        <a
          href={`webcal://api.comeals.${topLevel}/api/v1/communities/${Cookie.get(
            "community_id"
          )}/ical.ics`}
        >
          Subscribe to All Meals
        </a>
        <a
          href={`webcal://api.comeals.${topLevel}/api/v1/residents/${Cookie.get(
            "resident_id"
          )}/ical.ics`}
        >
          Subscribe to My Meals
        </a>
      </div>
    );
  }
}

export default WebcalLinks;
