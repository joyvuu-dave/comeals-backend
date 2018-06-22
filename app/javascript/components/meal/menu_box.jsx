import React from "react";
import { inject, observer } from "mobx-react";
import DebounceInput from "react-debounce-input";

const styles = {
  main: {
    gridArea: "a3",
    display: "grid",
    gridTemplateRows: "1fr 4fr",
    border: "0.5px solid"
  },
  text: {
    height: "100%",
    resize: "none",
    opacity: "1",
    visibility: "visible",
    fontSize: "1.25rem",
    whiteSpace: "pre-wrap"
  }
};

const MenuBox = inject("store")(
  observer(({ store }) => (
    <div style={styles.main} className="button-border-radius">
      <div className="flex space-between title">
        <h2 className="w-15">Menu</h2>
      </div>
      <div>
        <DebounceInput
          element="textarea"
          minLength={2}
          debounceTimeout={700}
          className={store.editDescriptionMode ? "" : "offwhite"}
          style={styles.text}
          value={store.meal && store.meal.description}
          onChange={e => store.setDescription(e.target.value)}
          disabled={!store.editDescriptionMode}
        />
      </div>
    </div>
  ))
);

export default MenuBox;
