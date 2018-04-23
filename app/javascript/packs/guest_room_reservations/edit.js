import React from "react";
import { render } from "react-dom";

import GuestRoomReservationsEdit from "../../components/guest_room_reservations/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;

  window.slug = data.slug;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  render(
    <GuestRoomReservationsEdit hosts={data.hosts} event={data.event} />,
    document.getElementById("main")
  );
});
