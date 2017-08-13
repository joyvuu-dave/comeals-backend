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
    color: "var(--color-primary)"
  },
  open: {
    color: "var(--color-green)"
  }
};

const DateBox = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <div className="flex middle space-between">
        <i
          className="fa fa-chevron-left fa-lg padding-right-medium"
          onClick={store.previousMeal}
        />
        <h2>
          {moment(store.meal.date).format("ddd, MMM Do")}
        </h2>
        <i
          className="fa fa-chevron-right fa-lg padding-left-medium"
          onClick={store.nextMeal}
        />
      </div>
      <br />
      <h1 style={store.meal.closed ? styles.closed : styles.open}>
        {store.meal.closed ? "CLOSED" : "OPEN"}
      </h1>
    </div>
  )
);

export default DateBox;
