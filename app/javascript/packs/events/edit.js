import "babel-polyfill";
import React from "react";
import ReactDOM from "react-dom";

import EventsEdit from "../../components/events/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const production = data.production;

  window.slug = data.slug;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  ReactDOM.render(<EventsEdit event={data.event} />, document.getElementById("main"));
});
