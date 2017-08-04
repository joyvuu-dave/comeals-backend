import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  gridArea: "a1",
  display: "flex",
  justifyContent: "space-between",
  backgroundColor: "gray",
  borderRadius: "var(--button-border-radius)"
};

const ButtonBar = inject("store")(
  observer(({ store }) =>
    <div style={styles}>
      <button
        className={store.editMode ? "button-inverse" : "button-danger"}
        onClick={store.toggleEditMode}
      >
        {store.editMode ? "Submit" : "Edit"}
      </button>
      <button className="button-info" onClick={store.history}>
        History
      </button>
    </div>
  )
);

export default ButtonBar;
