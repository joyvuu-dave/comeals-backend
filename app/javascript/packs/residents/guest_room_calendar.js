import "babel-polyfill";
import React from "react";
import ReactDOM from "react-dom";

import ResidentsGuestRoomCalendar from "../../components/residents/guest_room_calendar";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;

  window.community_id = data.community_id;
  window.comeals = data;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  ReactDOM.render(<ResidentsGuestRoomCalendar />, document.getElementById("calendar"));
});
