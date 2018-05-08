import React from "react";
import { render } from "react-dom";

import CommunitiesNew from "../../components/communities/new";

document.addEventListener("DOMContentLoaded", () => {
  render(<CommunitiesNew />, document.getElementById("main"));
});
