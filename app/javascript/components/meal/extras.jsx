import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    padding: "1rem 0 0 1rem",
    backgroundColor: "white"
  },
  open: {
    visibility: "hidden"
  },
  closed: {},
  title: {
    textDecoration: "underline"
  }
};

const Extras = inject("store")(
  observer(({ store }) => (
    <div style={styles.main}>
      <h5 style={styles.title}>Extras</h5>
      <div
        style={store.meal && store.meal.closed ? styles.closed : styles.open}
      >
        {[0, 1, 2, 3, 4, 5, 6, 7, 8].map(val => {
          return (
            <div key={val} className="pretty p-default p-round p-fill">
              <input
                key={val}
                type="checkbox"
                value={val}
                checked={store.meal ? store.meal.extras === val : false}
                onChange={e => store.meal.setExtras(e.target.value)}
                disabled={store.meal ? store.meal.reconciled : false}
              />
              <div className="state p-success">
                <label>{val}</label>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  ))
);

export default Extras;
