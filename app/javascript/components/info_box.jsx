import React from "react";
import { inject, observer } from "mobx-react";
import Extras from "./extras";
import CloseButton from "./close_button";

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
    border: "1px solid var(--state-primary)",
    height: "4.5rem",
    width: "4.5rem",
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
      <div className="title flex space-between">
        <h2>Signed Up</h2>
        <CloseButton />
      </div>
      <div className="flex space-between">
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
        <Extras />
      </div>
    </div>
  )
);

export default InfoBox;
