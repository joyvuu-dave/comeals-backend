import React, { Component } from "react";

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

class MealsEdit extends Component {
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

export default MealsEdit;
