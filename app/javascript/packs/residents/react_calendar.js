import React from "react";
import { render } from "react-dom";

import ResidentsReactCalendar from "../../components/residents/react_calendar";

document.addEventListener("DOMContentLoaded", () => {
  render(<ResidentsReactCalendar />, document.getElementById("main"));
});
