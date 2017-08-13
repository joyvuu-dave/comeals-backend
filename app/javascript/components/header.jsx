import React from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";
import ButtonBar from "./button_bar";

const styles = {
  header: {
    display: "flex",
    justifyContent: "space-between",
    height: "var(--input-height)",
    backgroundColor: "var(--hasana-yellow)"
  },
  black: {
    color: "var(--almost-black)"
  }
};

const Header = inject("store")(
  observer(({ store }) =>
    <header style={styles.header} id="header">
      <button
        className="button-link"
        style={styles.black}
        onClick={store.calendar}
      >
        Calendar
      </button>
      <div className="flex">
        <ButtonBar />
        <a
          style={styles.black}
          className="button button-link"
          onClick={store.logout}
        >
          logout
        </a>
      </div>
    </header>
  )
);

export default Header;
