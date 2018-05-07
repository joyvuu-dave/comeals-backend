import React from "react";
import { render } from "react-dom";

import GuestRoomReservationsNew from "../../components/guest_room_reservations/new";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  render(
    <GuestRoomReservationsNew hosts={data.hosts} />,
    document.getElementById("main")
  );
});
