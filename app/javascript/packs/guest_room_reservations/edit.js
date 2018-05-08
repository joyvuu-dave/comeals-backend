import React from "react";
import { render } from "react-dom";

import GuestRoomReservationsEdit from "../../components/guest_room_reservations/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  render(
    <GuestRoomReservationsEdit hosts={data.hosts} event={data.event} />,
    document.getElementById("main")
  );
});
