import React from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";

const styles = {
  main: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    flexDirection: "column",
    gridArea: "a1",
    border: "0.5px solid"
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
  observer(({ store }) => (
    <div style={styles.main} className="button-border-radius background-yellow">
      <div className="flex nowrap middle space-between">
        <div
          className="arrow"
          style={styles.arrow}
          onClick={store.previousMeal}
        >
          <i className="fa fa-chevron-left fa-3x pad-r-md" />
        </div>
        <h2>{moment(store.meal.date).format("ddd, MMM Do")}</h2>
        <div className="arrow" style={styles.arrow} onClick={store.nextMeal}>
          <i className="fa fa-chevron-right fa-3x pad-l-md" />
        </div>
      </div>
      <br />
      {store.meal.reconciled ? (
        <h1 className="text-black">RECONCILED</h1>
      ) : (
        <h1 className={store.meal.closed ? "text-primary" : "text-green"}>
          {store.meal.closed ? "CLOSED" : "OPEN"}
        </h1>
      )}
    </div>
  ))
);

export default DateBox;
