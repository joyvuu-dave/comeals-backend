import "babel-polyfill";
import React from "react";
import ReactDOM from "react-dom";

import ResidentsGuestRoom from "../../components/residents/guest_room";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;

  window.community_id = data.community_id;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  ReactDOM.render(<ResidentsGuestRoom />, document.getElementById("calendar"));
});
