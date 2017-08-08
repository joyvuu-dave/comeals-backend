import React from "react";
import { inject, observer } from "mobx-react";
import Extras from "./extras";

const styles = {
  main: {
    border: "0.5px solid",
    gridArea: "a5",
    borderRadius: "var(--button-border-radius)"
  },
  info: {
    marginTop: "1rem"
  },
  circle: {
    borderRadius: "50%",
    border: "1px solid var(--color-primary)",
    height: "75px",
    width: "75px",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    margin: "1rem 1rem 1rem 1rem"
  }
};

const InfoBox = inject("store")(
  observer(({ store }) =>
    <div className="offwhite" style={styles.main}>
      <div className="title">
        <h2>Attendees</h2>
      </div>
      <div className="flex">
        <h4 style={styles.circle}>
          <div>Total</div>
          <div>
            {store.attendeesCount}
          </div>
        </h4>
        <h4 style={styles.circle}>
          <div>Veg</div>
          <div>
            {store.vegetarianCount}
          </div>
        </h4>
        <h4 style={styles.circle}>
          <div>Late</div>
          <div>
            {store.lateCount}
          </div>
        </h4>
      </div>
      {store.meal.closed && <Extras />}
    </div>
  )
);

export default InfoBox;
