import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";
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
  },
  hidden: {
    visibility: "hidden"
  },
  shown: {
    visibility: "visible"
  }
};

const DateBox = inject("store", "routingStore")(
  withRouter(
    observer(
      class DateBox extends Component {
        constructor(props) {
          super(props);

          this.handlePrevClick = this.handlePrevClick.bind(this);
          this.handleNextClick = this.handleNextClick.bind(this);
        }

        componentDidUpdate() {
          var pathNameArray = this.props.routingStore.router.location.pathname.split(
            "/"
          );
          var mealId = pathNameArray[pathNameArray.length - 2];

          if (store.meal) {
            if (Number.parseInt(mealId, 10) !== store.meal.id) {
              store.goToMeal(mealId);
            }
          }
        }

        handlePrevClick() {
          this.props.routingStore.router.push(
            `/meals/${store.meal.prevId}/edit`
          );
        }

        handleNextClick() {
          this.props.routingStore.router.push(
            `/meals/${store.meal.nextId}/edit`
          );
        }

        displayDate() {
          if (store.meal.date === null) {
            return "";
          }

          var today = moment([
            moment().year(),
            moment().month(),
            moment().date()
          ]);
          var days = moment(store.meal.date).diff(today, "days");

          if (days === 0) return "Today";
          if (days === -1) return "Yesterday";
          if (days === 1) return "Tomorrow";
          return moment(store.meal.date).from(today);
        }

        render() {
          return (
            <div
              style={styles.main}
              className="button-border-radius background-yellow"
            >
              <div className="flex nowrap middle space-between">
                <div
                  className="arrow"
                  style={styles.arrow}
                  onClick={this.handlePrevClick}
                >
                  <i className="fas fa-chevron-left fa-3x pad-r-md" />
                </div>
                <h2>
                  {store.meal.date === null
                    ? ""
                    : moment(store.meal.date).format("ddd, MMM Do")}
                </h2>
                <div
                  className="arrow"
                  style={styles.arrow}
                  onClick={this.handleNextClick}
                >
                  <i className="fas fa-chevron-right fa-3x pad-r-md" />
                </div>
              </div>
              <h3 className="text-black">{this.displayDate()}</h3>
              {store.meal.reconciled ? (
                <h1
                  className="text-black"
                  style={store.isLoading ? styles.hidden : styles.shown}
                >
                  RECONCILED
                </h1>
              ) : (
                <h1
                  className={store.meal.closed ? "text-primary" : "text-green"}
                  style={store.isLoading ? styles.hidden : styles.shown}
                >
                  {store.meal.closed ? "CLOSED" : "OPEN"}
                </h1>
              )}
            </div>
          );
        }
      }
    )
  )
);

export default DateBox;
