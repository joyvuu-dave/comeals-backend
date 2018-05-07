import React from "react";
import { render } from "react-dom";

import ResidentsPasswordReset from "../../components/residents/password_reset";

document.addEventListener("DOMContentLoaded", () => {
  render(<ResidentsPasswordReset />, document.getElementById("main"));
});
