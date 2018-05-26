import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    gridArea: "a1",
    display: "flex",
    justifyContent: "space-between"
  }
};

const ButtonBar = inject("store")(
  observer(({ store }) => (
    <div style={styles.main} className="button-border-radius">
      <button
        className="button-link text-secondary"
        onClick={store.toggleHistory}
      >
        history
      </button>
    </div>
  ))
);

export default ButtonBar;
