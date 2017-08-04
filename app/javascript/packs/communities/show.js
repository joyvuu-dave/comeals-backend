import React from "react";
import ReactDOM from "react-dom";

import CommunitiesShow from "../../components/communities/show";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("community");
  const data = JSON.parse(node.getAttribute("data"));
  const id = Number.parseInt(data.id);
  const name = data.name;

  ReactDOM.render(
    <CommunitiesShow id={id} name={name} />,
    document.getElementById("root")
  );
});
