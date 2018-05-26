import React from "react";
import { render } from "react-dom";

import ResidentsPasswordNew from "../../components/residents/password_new";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  const token = data.token;
  const name = data.name;

  render(
    <ResidentsPasswordNew token={token} name={name} />,
    document.getElementById("main")
  );
});
