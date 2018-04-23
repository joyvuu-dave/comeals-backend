import React from "react";
import { render } from "react-dom";

import CommonHouseReservationsNew from "../../components/common_house_reservations/new";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;

  window.community_id = data.community_id;
  window.slug = data.slug;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  render(
    <CommonHouseReservationsNew residents={data.residents} />,
    document.getElementById("main")
  );
});
