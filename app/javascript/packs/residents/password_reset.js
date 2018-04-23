import React from "react";
import { render } from "react-dom";

import ResidentsPasswordReset from "../../components/residents/password_reset";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  render(<ResidentsPasswordReset />, document.getElementById("main"));
});
