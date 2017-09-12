import React from "react";
import Cookie from "js-cookie";

const Footer = () => (
  <footer>
    <h4 className="text-center text-secondary">
      Created by{" "}
      <a
        href="https://github.com/joyvuu-dave/comeals-rewrite"
        target="_blank"
        className="text-secondary"
      >
        David
      </a>
      <span className="text-small">{` v${Cookie.get("version")}`}</span>
    </h4>
  </footer>
);

export default Footer;
