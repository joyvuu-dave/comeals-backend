import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    gridArea: "a1",
    display: "flex",
    justifyContent: "space-between",
    borderRadius: "var(--button-border-radius)"
  },
  black: {
    color: "var(--almost-black)"
  }
};

const ButtonBar = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <button
        className="button-link"
        style={styles.black}
        onClick={store.history}
      >
        history
      </button>
    </div>
  )
);

export default ButtonBar;
