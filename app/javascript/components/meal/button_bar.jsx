import React, { Component } from "react";
import { inject, observer } from "mobx-react";

const styles = {
  main: {
    gridArea: "a1",
    display: "flex",
    justifyContent: "space-between"
  }
};

const ButtonBar = inject("store")(
  observer(
    class ButtonBar extends Component {
      constructor(props) {
        super(props);
        this.toggleHistory = this.toggleHistory.bind(this);
      }

      toggleHistory() {
        if (this.props.match.params.history === "history") {
          this.props.history.push(this.props.match.url.split("/history")[0]);
        } else {
          this.props.history.push(`${this.props.match.url}history`);
        }
      }

      render() {
        return (
          <div style={styles.main} className="button-border-radius">
            <button
              className="button-link text-secondary"
              onClick={this.toggleHistory}
            >
              history
            </button>
          </div>
        );
      }
    }
  )
);

export default ButtonBar;
