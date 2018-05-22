import React from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";
import ButtonBar from "./button_bar";

const styles = {
  header: {
    display: "flex",
    justifyContent: "space-between"
  }
};

const Header = inject("store")(
  observer(({ store }) => (
    <header
      style={styles.header}
      className="header background-yellow input-height"
    >
      <button className="button-link text-black" onClick={store.calendar}>
        Calendar
      </button>
      <div className="flex">
        <ButtonBar />
        <a className="button button-link text-secondary" onClick={store.logout}>
          logout
        </a>
      </div>
    </header>
  ))
);

export default Header;
