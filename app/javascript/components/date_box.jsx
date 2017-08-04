import React from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";

const styles = {
  main: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    flexDirection: "column",
    gridArea: "a2",
    borderTop: "0.5px solid",
    borderLeft: "0.5px solid",
    borderBottom: "0.5px solid",
    borderRadius: "var(--button-border-radius)",
    backgroundColor: "var(--hasana-yellow)"
  },
  closed: {
    color: "var(--button-bg-color-primary)"
  }
};

const DateBox = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <h2>
        {moment(store.meal.date).format("ddd, MMM Do")}
      </h2>
      <button className="button-success" onClick={store.calendar}>
        Calendar
      </button>
      <br />
      {store.meal.closed && <h1 style={styles.closed}>CLOSED</h1>}
    </div>
  )
);

export default DateBox;
