import React from "react";
import { render } from "react-dom";

import ResidentsLogin from "../../components/residents/login";

document.addEventListener("DOMContentLoaded", () => {
  render(<ResidentsLogin />, document.getElementById("resident_login"));
});
