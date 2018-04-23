import React from "react";
import { render } from "react-dom";

import ResidentsLogin from "../../components/residents/login";

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

  render(<ResidentsLogin />, document.getElementById("resident_login"));
});
