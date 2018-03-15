import "babel-polyfill";
import React from "react";
import ReactDOM from "react-dom";

import GuestRoomReservationsEdit from "../../components/guest_room_reservations/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  ReactDOM.render(<GuestRoomReservationsEdit hosts={data.hosts}/>, document.getElementById("main"));
});
