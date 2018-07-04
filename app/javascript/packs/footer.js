import React from "react";
import { render } from "react-dom";

import Footer from "../components/app/footer";

document.addEventListener("DOMContentLoaded", () => {
  render(<Footer />, document.getElementById("footer"));
});
