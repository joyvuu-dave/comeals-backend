import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    padding: "1rem 0 0 1rem",
    backgroundColor: "white"
  },
  title: {
    textDecoration: "underline"
  }
};

const Extras = inject("store")(
  observer(({ store }) =>
    <div style={styles.main} className="width-75">
      <h5 style={styles.title}>Extras</h5>
      {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(val => {
        return (
          <div key={val} className="pretty circle success">
            <input
              key={val}
              type="radio"
              value={val}
              checked={store.meal.extras === val}
              onChange={e => store.meal.setExtras(e.target.value)}
            />
            <label>
              <i className="fa fa-check" />
              {val}{" "}
            </label>
          </div>
        );
      })}
    </div>
  )
);

export default Extras;
