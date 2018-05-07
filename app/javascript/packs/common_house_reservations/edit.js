import React from "react";
import { render } from "react-dom";

import CommonHouseReservationsEdit from "../../components/common_house_reservations/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  render(
    <CommonHouseReservationsEdit
      residents={data.residents}
      event={data.event}
    />,
    document.getElementById("main")
  );
});
