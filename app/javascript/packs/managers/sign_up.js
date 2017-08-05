import React from "react";
import ReactDOM from "react-dom";

import ManagersSignUp from "../../components/managers/sign_up";

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

  ReactDOM.render(<ManagersSignUp />, document.getElementById("root"));
});
