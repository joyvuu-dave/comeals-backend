import React from "react";
import axios from "axios";
import { inject, observer } from "mobx-react";
import Cow from "../packs/images/cow.png";
import Carrot from "../packs/images/carrot.png";

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
  },
  pointer: {
    cursor: "pointer"
  },
  icon: {
    maxHeight: "1rem"
  },
  sticky: {
    position: "sticky",
    top: 0,
    backgroundColor: "var(--almost-white)",
    zIndex: "9999"
  },
  disabled: {
    cursor: "not-allowed",
    opacity: "0.5"
  }
};

const AttendeeComponent = inject("store")(
  observer(
    class AttendeeComponent extends React.Component {
      render() {
        const resident = this.props.resident;
        const guests = resident.guests;
        const vegGuestsCount = guests.filter(guest => guest.vegetarian === true)
          .length;
        const meatGuestsCount = guests.filter(
          guest => guest.vegetarian === false
        ).length;

        return (
          <tr>
            <td
              onClick={e => resident.toggleAttending()}
              style={Object.assign(
                {},
                resident.attending && styles.yes,
                !resident.attending && styles.no,
                resident.attending && !resident.canRemove && styles.disabled
              )}
            >
              {resident.name}
            </td>
            <td>
              {vegGuestsCount > 0 &&
                <span className="badge badge-info margin-right-small">
                  {vegGuestsCount}
                  <img src={Carrot} style={styles.icon} alt="carrot-icon" />
                </span>}
              {meatGuestsCount > 0 &&
                <span className="badge badge-info">
                  {meatGuestsCount}
                  <img src={Cow} style={styles.icon} alt="cow-icon" />
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
                  disabled={
                    store.meal.closed &&
                    !resident.attending &&
                    store.meal.extras < 1
                  }
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
                  disabled={
                    (store.meal.closed && resident.attending) ||
                    (store.meal.closed && store.meal.extras < 1)
                  }
                />
                <label htmlFor={`veg_switch_${resident.id}`} />
              </span>
            </td>
            <td>
              <div className="dropdown">
                <button
                  className="dropdown-trigger margin-right-small"
                  style={styles.topButton}
                  disabled={!store.canAdd}
                >
                  + Guest
                </button>
                <div className="dropdown-menu">
                  <a onClick={e => resident.addGuest({ vegetarian: false })}>
                    <img src={Cow} style={styles.pointer} alt="cow-icon" />
                  </a>
                  <a onClick={e => resident.addGuest({ vegetarian: true })}>
                    <img
                      src={Carrot}
                      style={styles.pointer}
                      alt="carrot-icon"
                    />
                  </a>
                </div>
              </div>
              <button
                style={styles.lowerButton}
                onClick={e => resident.removeGuest()}
                disabled={!resident.canRemoveGuest}
              >
                - Guest
              </button>
            </td>
          </tr>
        );
      }
    }
  )
);

const AttendeeForm = inject("store")(
  observer(
    class AttendeeForm extends React.Component {
      render() {
        return (
          <div style={styles.main}>
            <table className="table-striped" style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.sticky}>
                    Name{" "}
                    <span className="text-small text-italic text-secondary text-nowrap">
                      (click to add)
                    </span>
                  </th>
                  <th style={styles.sticky}>Guests</th>
                  <th style={styles.sticky}>Late</th>
                  <th style={styles.sticky}>Veg</th>
                  <th style={styles.sticky} />
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
        );
      }
    }
  )
);

export default AttendeeForm;
