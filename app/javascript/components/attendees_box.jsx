import React from "react";
import axios from "axios";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    margin: "1em 0 1em 0",
    gridArea: "a6"
  },
  table: {
    backgroundColor: "var(--almost-white)"
  },
  topButton: {
    marginBottom: "1px",
    fontFamily: "var(--font-monospace)"
  },
  lowerButton: {
    fontFamily: "var(--font-monospace)"
  },
  yes: {
    backgroundColor: "var(--color-green)",
    cursor: "pointer",
    color: "var(--almost-white)"
  },
  no: {
    cursor: "pointer"
  }
};

const AttendeeComponent = inject("store")(
  observer(({ store, resident }) =>
    <tr>
      <td
        onClick={e => resident.toggleAttending()}
        style={resident.attending ? styles.yes : styles.no}
      >
        {resident.name}{" "}
        {resident.guests > 0 &&
          <span className="badge badge-info">
            {resident.guests} {resident.guests === 1 ? "Guest" : "Guests"}
          </span>}
      </td>
      <td>
        <span className="switch">
          <input
            id={`late_switch_${resident.id}`}
            type="checkbox"
            className="switch"
            key={`late_switch_${resident.id}`}
            defaultChecked={resident.late}
            onClick={e => resident.toggleLate()}
          />
          <label htmlFor={`late_switch_${resident.id}`} />
        </span>
      </td>
      <td>
        <span className="switch">
          <input
            id={`veg_switch_${resident.id}`}
            type="checkbox"
            className="switch"
            key={`veg_switch_${resident.id}`}
            defaultChecked={resident.vegetarian}
            onClick={e => resident.toggleVeg()}
            disabled={store.meal.closed}
          />
          <label htmlFor={`veg_switch_${resident.id}`} />
        </span>
      </td>
      <td>
        <button
          style={styles.topButton}
          onClick={e => resident.addGuest()}
          disabled={!store.canAdd}
        >
          + Guest
        </button>{" "}
        <button
          style={styles.lowerButton}
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
      <table className="table-striped" style={styles.table}>
        <thead>
          <tr>
            <th>
              Name{" "}
              <span className="text-small text-italic text-muted">
                (click to add)
              </span>
            </th>
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
