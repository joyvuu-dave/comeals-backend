import React from "react";
import { inject, observer } from "mobx-react";
import Extras from "./extras";

const styles = {
  borderBottom: "0.5px solid",
  borderRight: "0.5px solid",
  borderLeft: "0.5px solid",
  gridArea: "a5",
  borderRadius: "var(--button-border-radius"
};

const InfoBox = inject("store")(
  observer(({ store }) =>
    <div style={styles}>
      <h2 className="title">Attendees</h2>
      <ul>
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
