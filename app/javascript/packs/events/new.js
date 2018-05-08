import React from "react";
import { render } from "react-dom";

import EventsNew from "../../components/events/new";

document.addEventListener("DOMContentLoaded", () => {
  render(<EventsNew />, document.getElementById("main"));
});
