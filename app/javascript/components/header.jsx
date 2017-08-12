import React from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";

const styles = {
  header: {
    display: "flex",
    justifyContent: "flex-end",
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
      <a
        style={styles.black}
        className="button button-link"
        onClick={store.logout}
      >
        logout
      </a>
    </header>
  )
);

export default Header;
