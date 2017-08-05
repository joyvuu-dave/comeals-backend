import React from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    padding: "1rem 0 0 1rem"
  }
};

const Extras = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <h5>Extras</h5>
      {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].map(val => {
        return (
          <span key={val}>
            <input
              key={val}
              type="radio"
              value={val}
              checked={store.meal.extras === val}
              onChange={e => store.meal.setExtras(e.target.value)}
            />
            {val}{" "}
          </span>
        );
      })}
    </div>
  )
);

export default Extras;
