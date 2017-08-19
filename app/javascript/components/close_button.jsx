import React from "react";
import { inject, observer } from "mobx-react";

const CloseButton = inject("store")(
  observer(({ store }) =>
    <button
      onClick={store.toggleClosed}
      className={store.meal.closed ? "button-danger" : "button-success"}
    >
      Open / Close Meal
    </button>
  )
);

export default CloseButton;
