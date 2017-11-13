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
      <div style={store.meal.closed ? styles.closed : styles.open}>
        {[0, 1, 2, 3, 4, 5, 6, 7, 8].map(val => {
          return (
            <div key={val} className="pretty circle success">
              <input
                key={val}
                type="radio"
                value={val}
                checked={store.meal.extras === val}
                onChange={e => store.meal.setExtras(e.target.value)}
                disabled={store.meal.reconciled}
              />
              <label>
                <i className="fa fa-check" />
                {val}{" "}
              </label>
            </div>
          );
        })}
      </div>
    </div>
  ))
);

export default Extras;
