import React, { Component } from "react";
import { inject, observer } from "mobx-react";
import { withRouter } from "react-router";

import Header from "../meal/header";
import Extras from "../meal/extras";
import ButtonBar from "../meal/button_bar";
import DateBox from "../meal/date_box";
import MenuBox from "../meal/menu_box";
import CooksBox from "../meal/cooks_box";
import InfoBox from "../meal/info_box";
import AttendeesBox from "../meal/attendees_box";

const styles = {
  section: {
    margin: "1em 0 1em 0"
  }
};

const MealsEdit = inject("store")(
  withRouter(
    observer(
      class MealsEdit extends Component {
        constructor(props) {
          super(props);
        }

        componentDidMount() {
          console.log("meal: i mounted");
          var pathNameArray = this.props.store.router.location.pathname.split(
            "/"
          );
          var pathName = pathNameArray[pathNameArray.length - 2];
          this.props.store.goToMeal(pathName);
        }

        componentDidUpdate() {
          console.log("meal: i updated");
        }

        render() {
          return (
            <div className="comeals-container">
              <Header />
              <div className="comeals-container">
                <section style={styles.section}>
                  <div className="wrapper">
                    <DateBox />
                    <MenuBox />
                    <CooksBox />
                    <InfoBox />
                    <AttendeesBox />
                  </div>
                </section>
              </div>
            </div>
          );
        }
      }
    )
  )
);

export default MealsEdit;
