import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";
import moment from "moment";

import FontAwesomeIcon from "@fortawesome/react-fontawesome";
import faChevronLeft from "@fortawesome/fontawesome-free-solid/faChevronLeft";
import faChevronRight from "@fortawesome/fontawesome-free-solid/faChevronRight";

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

const DateBox = inject("store")(
  withRouter(
    observer(
      class DateBox extends Component {
        constructor(props) {
          super(props);

          this.handlePrevClick = this.handlePrevClick.bind(this);
          this.handleNextClick = this.handleNextClick.bind(this);
        }

        componentDidUpdate() {
          var pathNameArray = this.props.store.router.location.pathname.split(
            "/"
          );
          var mealId = pathNameArray[2];

          if (store.meal) {
            if (Number.parseInt(mealId, 10) !== store.meal.id) {
              store.goToMeal(mealId);
            }
          }
        }

        componentDidMount() {
          store.goToMeal(store.router.location.pathname.split("/")[2]);
        }

        handlePrevClick() {
          store.router.push(`/meals/${store.meal.prevId}/edit`);
        }

        handleNextClick() {
          store.router.push(`/meals/${store.meal.nextId}/edit`);
        }

        displayDate() {
          if (store.meal === null) {
            return "loading...";
          }

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

        displayTopDate() {
          if (store.meal === null) {
            return "";
          }

          if (store.meal.date === null) {
            return "";
          }

          return moment(store.meal.date).format("ddd, MMM Do");
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
                  <FontAwesomeIcon icon={faChevronLeft} size="3x" />
                </div>
                <h2>{this.displayTopDate()}</h2>
                <div
                  className="arrow"
                  style={styles.arrow}
                  onClick={this.handleNextClick}
                >
                  <FontAwesomeIcon icon={faChevronRight} size="3x" />
                </div>
              </div>
              <h3 className="text-black">{this.displayDate()}</h3>
              {store.meal && store.meal.reconciled ? (
                <h1
                  className="text-black"
                  style={store.isLoading ? styles.hidden : styles.shown}
                >
                  RECONCILED
                </h1>
              ) : (
                <h1
                  className={
                    store.meal && store.meal.closed
                      ? "text-primary"
                      : "text-green"
                  }
                  style={store.isLoading ? styles.hidden : styles.shown}
                >
                  {store.meal && store.meal.closed ? "CLOSED" : "OPEN"}
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
