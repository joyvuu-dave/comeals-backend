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
    border: "0.5px solid",
    borderRadius: "var(--button-border-radius)",
    backgroundColor: "var(--hasana-yellow)"
  },
  closed: {
    color: "var(--state-primary)"
  },
  open: {
    color: "var(--color-green)"
  },
  reconciled: {
    color: "var(--almost-black)"
  },
  arrow: {
    height: "5rem",
    width: "4rem",
    display: "flex",
    flexFlow: "column",
    justifyContent: "center",
    alignItems: "center"
  }
};

const DateBox = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <div className="flex nowrap middle space-between">
        <div
          className="arrow"
          style={styles.arrow}
          onClick={store.previousMeal}
        >
          <i className="fa fa-chevron-left fa-3x padding-right-medium" />
        </div>
        <h2>
          {moment(store.meal.date).format("ddd, MMM Do")}
        </h2>
        <div className="arrow" style={styles.arrow} onClick={store.nextMeal}>
          <i className="fa fa-chevron-right fa-3x padding-left-medium" />
        </div>
      </div>
      <br />
      {store.meal.reconciled
        ? <h1 style={styles.reconciled}>RECONCILED</h1>
        : <h1 style={store.meal.closed ? styles.closed : styles.open}>
            {store.meal.closed ? "CLOSED" : "OPEN"}
          </h1>}
    </div>
  )
);

export default DateBox;
