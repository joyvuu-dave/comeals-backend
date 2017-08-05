import React from "react";
import axios from "axios";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    minHeight: "var(--section-height)"
  },
  table: {
    backgroundColor: "hsl(0, 0%, 98%)"
  }
};

const AttendeeComponent = inject("store")(
  observer(({ store, resident }) =>
    <tr>
      <td>
        {resident.name}{" "}
        {resident.guests > 0 &&
          <span className="badge badge-info">
            {resident.guests} {resident.guests === 1 ? "Guest" : "Guests"}
          </span>}
      </td>
      <td>
        <input
          type="checkbox"
          checked={resident.attending}
          onChange={e => resident.setAttending(e.target.checked)}
          disabled={!store.canAdd || (resident.attending && store.meal.closed)}
        />
      </td>
      <td>
        <input
          type="checkbox"
          checked={resident.late}
          onChange={e => resident.setLate(e.target.checked)}
          disabled={!resident.attending}
        />
      </td>
      <td>
        <input
          type="checkbox"
          checked={resident.vegetarian}
          onChange={e => resident.setVegetarian(e.target.checked)}
          disabled={store.meal.closed || !resident.attending}
        />
      </td>
      <td>
        <button onClick={e => resident.addGuest()} disabled={!store.canAdd}>
          + Guest
        </button>{" "}
        <button
          onClick={e => resident.removeGuest()}
          disabled={store.meal.closed || resident.guests === 0}
        >
          - Guest
        </button>
      </td>
    </tr>
  )
);

const AttendeeForm = inject("store")(
  observer(({ store }) =>
    <div style={styles.main}>
      <button onClick={store.toggleClosed}>
        {store.meal.closed ? "Re-Open Meal" : "Close Meal"}
      </button>
      <table className="table-striped" style={styles.table}>
        <thead>
          <tr>
            <th>Name</th>
            <th>Attending</th>
            <th>Late</th>
            <th>Veg</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {store.residents
            .values()
            .map(resident =>
              <AttendeeComponent key={resident.id} resident={resident} />
            )}
        </tbody>
      </table>
    </div>
  )
);

export default AttendeeForm;
