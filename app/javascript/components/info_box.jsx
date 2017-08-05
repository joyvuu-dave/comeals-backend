import React from "react";
import { inject, observer } from "mobx-react";
import Extras from "./extras";

const styles = {
  main: {
    border: "0.5px solid",
    gridArea: "a5",
    borderRadius: "var(--button-border-radius"
  },
  info: {
    marginTop: "1rem"
  }
};

const InfoBox = inject("store")(
  observer(({ store }) =>
    <div className="offwhite" style={styles.main}>
      <div className="title">
        <h2>Attendees</h2>
      </div>
      <ul style={styles.info}>
        <li>
          Total: {store.attendeesCount}
        </li>
        <li>
          Veg: {store.vegetarianCount}
        </li>
        <li>
          Late: {store.lateCount}
        </li>
      </ul>
      {store.meal.closed && <Extras />}
    </div>
  )
);

export default InfoBox;
