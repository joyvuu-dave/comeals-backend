import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router-dom";
import moment from "moment";
import Modal from "react-modal";

import FontAwesomeIcon from "@fortawesome/react-fontawesome";
import faChevronLeft from "@fortawesome/fontawesome-free-solid/faChevronLeft";
import faChevronRight from "@fortawesome/fontawesome-free-solid/faChevronRight";

import MealHistoryShow from "../history/show";

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

Modal.setAppElement("#main");
const DateBox = inject("store")(
  withRouter(
    observer(
      class DateBox extends Component {
        constructor(props) {
          super(props);

          this.handlePrevClick = this.handlePrevClick.bind(this);
          this.handleNextClick = this.handleNextClick.bind(this);
          this.handleCloseModal = this.handleCloseModal.bind(this);
        }

        componentDidUpdate() {
          var pathNameArray = this.props.location.pathname.split("/");
          var mealId = pathNameArray[2];

          if (this.props.store.meal) {
            if (Number.parseInt(mealId, 10) !== this.props.store.meal.id) {
              this.props.store.goToMeal(mealId);
            }
          }
        }

        componentDidMount() {
          this.props.store.goToMeal(this.props.location.pathname.split("/")[2]);
        }

        renderModal() {
          if (this.props.match.params.history !== "history") {
            return null;
          }

          return (
            <MealHistoryShow
              id={this.props.store.meal.id}
              date={moment(this.props.store.meal.date).format("ddd, MMM Do")}
            />
          );
        }

        handleCloseModal() {
          //this.props.store.toggleHistory();

          this.props.history.push(
            `${this.props.match.url.split("/history")[0]}`
          );
        }

        handlePrevClick() {
          if (this.props.store.isLoading) {
            return;
          }

          this.props.history.push(
            `/meals/${this.props.store.meal.prevId}/edit`
          );
        }

        handleNextClick() {
          if (this.props.store.isLoading) {
            return;
          }

          this.props.history.push(
            `/meals/${this.props.store.meal.nextId}/edit`
          );
        }

        displayDate() {
          if (this.props.store.meal === null) {
            return "loading...";
          }

          if (this.props.store.meal.date === null) {
            return "";
          }

          var today = moment([
            moment().year(),
            moment().month(),
            moment().date()
          ]);
          var days = moment(this.props.store.meal.date).diff(today, "days");

          if (days === 0) return "Today";
          if (days === -1) return "Yesterday";
          if (days === 1) return "Tomorrow";
          return moment(this.props.store.meal.date).from(today);
        }

        displayTopDate() {
          if (this.props.store.meal === null) {
            return "";
          }

          if (this.props.store.meal.date === null) {
            return "";
          }

          return moment(this.props.store.meal.date).format("ddd, MMM Do");
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
                  disabled={this.props.store.isLoading}
                >
                  <FontAwesomeIcon icon={faChevronLeft} size="3x" />
                </div>
                <h2>{this.displayTopDate()}</h2>
                <div
                  className="arrow"
                  style={styles.arrow}
                  onClick={this.handleNextClick}
                  disabled={this.props.store.isLoading}
                >
                  <FontAwesomeIcon icon={faChevronRight} size="3x" />
                </div>
              </div>
              <h3 className="text-black">{this.displayDate()}</h3>
              {this.props.store.meal && this.props.store.meal.reconciled ? (
                <h1
                  className="text-black"
                  style={
                    this.props.store.isLoading ? styles.hidden : styles.shown
                  }
                >
                  RECONCILED
                </h1>
              ) : (
                <h1
                  className={
                    this.props.store.meal && this.props.store.meal.closed
                      ? "text-primary"
                      : "text-green"
                  }
                  style={
                    this.props.store.isLoading ? styles.hidden : styles.shown
                  }
                >
                  {this.props.store.meal && this.props.store.meal.closed
                    ? "CLOSED"
                    : "OPEN"}
                </h1>
              )}
              <Modal
                isOpen={typeof this.props.match.params.history !== "undefined"}
                contentLabel="History Modal"
                onRequestClose={this.handleCloseModal}
                style={{
                  content: {
                    backgroundColor: "#6699cc"
                  }
                }}
              >
                {this.renderModal()}
              </Modal>
            </div>
          );
        }
      }
    )
  )
);

export default DateBox;
