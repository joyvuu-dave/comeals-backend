import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import moment from "moment";
import ButtonBar from "./button_bar";
import Cookie from "js-cookie";

const styles = {
  header: {
    display: "flex",
    justifyContent: "space-between"
  }
};

const Header = inject("store")(
  observer(
    class Header extends Component {
      render() {
        return (
          <header
            style={styles.header}
            className="header background-yellow input-height"
          >
            <button
              onClick={() =>
                this.props.history.push(
                  `/calendar/all/${moment(
                    this.props.store.isLoading
                      ? new Date()
                      : this.props.store.meal.date
                  ).format("YYYY-MM-DD")}`
                )
              }
              className="text-black button-link"
            >
              Calendar
            </button>
            {this.props.store.isOnline ? (
              <span className="online">ONLINE</span>
            ) : (
              <span className="offline">OFFLINE</span>
            )}
            <div className="flex">
              <ButtonBar
                history={this.props.history}
                location={this.props.location}
                match={this.props.match}
              />
              <a
                className="button button-link text-secondary"
                onClick={this.props.store.logout}
              >
                logout {Cookie.get("username")}
              </a>
            </div>
          </header>
        );
      }
    }
  )
);

export default Header;
