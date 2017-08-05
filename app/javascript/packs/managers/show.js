import React from "react";
import ReactDOM from "react-dom";

import ManagersShow from "../../components/managers/show";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("meal-id");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".dev";
  }

  ReactDOM.render(<ManagersShow />, document.getElementById("root"));
});
