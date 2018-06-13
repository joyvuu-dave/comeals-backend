import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import Cow from "../../images/cow.png";
import Carrot from "../../images/carrot.png";
import GuestDropdown from "./guest_dropdown";

const styles = {
  main: {
    margin: "1em 0 1em 0",
    gridArea: "a5"
  },
  icon: {
    maxHeight: "1rem"
  },
  sticky: {
    position: "sticky",
    top: 0,
    zIndex: "9999"
  },
  disabled: {
    cursor: "not-allowed",
    opacity: "0.5"
  }
};

const AttendeeComponent = inject("store")(
  observer(
    class AttendeeComponent extends Component {
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
              className={
                resident.attending
                  ? "background-green text-white pointer background-transition"
                  : "pointer background-transition"
              }
              style={Object.assign(
                {},
                resident.attending && !resident.canRemove && styles.disabled,
                this.props.store.meal.reconciled && styles.disabled
              )}
            >
              {resident.name}
            </td>
            <td>
              {vegGuestsCount > 0 && (
                <span className="badge badge-info mar-r-sm">
                  {vegGuestsCount}
                  <img src={Carrot} style={styles.icon} alt="carrot-icon" />
                </span>
              )}
              {meatGuestsCount > 0 && (
                <span className="badge badge-info">
                  {meatGuestsCount}
                  <img src={Cow} style={styles.icon} alt="cow-icon" />
                </span>
              )}
            </td>
            <td>
              <span className="switch">
                <input
                  id={`late_switch_${resident.id}`}
                  type="checkbox"
                  className="switch"
                  key={`late_switch_${resident.id}`}
                  checked={resident ? resident.late : false}
                  onChange={e => resident.toggleLate()}
                  disabled={
                    this.props.store.meal.reconciled ||
                    (this.props.store.meal.closed &&
                      !resident.attending &&
                      this.props.store.meal.extras < 1)
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
                  checked={resident ? resident.vegetarian : false}
                  onChange={e => resident.toggleVeg()}
                  disabled={
                    this.props.store.meal.reconciled ||
                    (this.props.store.meal.closed &&
                      resident.attending &&
                      !resident.canRemove) ||
                    (this.props.store.meal.closed &&
                      !resident.attending &&
                      this.props.store.meal.extras < 1)
                  }
                />
                <label htmlFor={`veg_switch_${resident.id}`} />
              </span>
            </td>
            <td>
              <GuestDropdown
                resident={resident}
                reconciled={this.props.store.meal.reconciled}
                canAdd={this.props.store.canAdd}
              />
              <button
                className="monospace"
                onClick={e => resident.removeGuest()}
                disabled={
                  this.props.store.meal.reconciled || !resident.canRemoveGuest
                }
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

const AttendeesBox = inject("store")(
  observer(
    class AttendeesBox extends Component {
      render() {
        return (
          <div style={styles.main}>
            <table className="background-white">
              <thead>
                <tr>
                  <th style={styles.sticky} className="background-white">
                    Name{" "}
                    <span className="text-small text-italic text-secondary text-nowrap">
                      (click to add)
                    </span>
                  </th>
                  <th style={styles.sticky} className="background-white">
                    Guests
                  </th>
                  <th style={styles.sticky} className="background-white">
                    Late
                  </th>
                  <th style={styles.sticky} className="background-white">
                    Veg
                  </th>
                  <th style={styles.sticky} />
                </tr>
              </thead>
              <tbody>
                {Array.from(this.props.store.residents.values()).map(
                  resident => (
                    <AttendeeComponent key={resident.id} resident={resident} />
                  )
                )}
              </tbody>
            </table>
          </div>
        );
      }
    }
  )
);

export default AttendeesBox;
