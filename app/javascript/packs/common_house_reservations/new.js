import React from "react";
import { render } from "react-dom";

import CommonHouseReservationsNew from "../../components/common_house_reservations/new";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  render(
    <CommonHouseReservationsNew residents={data.residents} />,
    document.getElementById("main")
  );
});
