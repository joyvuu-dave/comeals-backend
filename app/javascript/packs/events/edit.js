import React from "react";
import { render } from "react-dom";

import EventsEdit from "../../components/events/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  render(<EventsEdit event={data.event} />, document.getElementById("main"));
});
