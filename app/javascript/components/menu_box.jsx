import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    gridArea: "a3",
    display: "grid",
    gridTemplateRows: "1fr 4fr",
    border: "0.5px solid",
    borderRadius: "var(--button-border-radius"
  },
  text: {
    height: "100%",
    resize: "none"
  }
};

const MenuBox = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <h2 className="title">Menu</h2>
      <textarea
        className={store.editMode ? "" : "offwhite"}
        style={styles.text}
        value={store.meal.description}
        onChange={store.setDescription}
        disabled={!store.editMode}
      />
    </div>
  )
);

export default MenuBox;
