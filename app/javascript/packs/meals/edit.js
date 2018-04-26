import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";
import Pusher from "pusher-js";

import { DataStore } from "../../stores/data_store";

import Header from "../../components/header";
import Extras from "../../components/extras";
import ButtonBar from "../../components/button_bar";
import DateBox from "../../components/date_box";
import MenuBox from "../../components/menu_box";
import CooksBox from "../../components/cooks_box";
import InfoBox from "../../components/info_box";
import AttendeesBox from "../../components/attendees_box";

document.addEventListener("DOMContentLoaded", () => {
  const styles = {
    section: {
      margin: "1em 0 1em 0"
    }
  };

  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const id = parseInt(data.id);

  // Gotta format our date obj because JavaScript
  const dateArray = data.date.split("-");
  const date = new Date(
    dateArray[0],
    Number(dateArray[1] - 1),
    Number(dateArray[2])
  );

  const production = data.production;
  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".test";
  }

  const store = DataStore.create({
    meal: id,
    meals: [{ id: id, date: date }]
  });

  window.store = store;

  var pusher = new Pusher("8affd7213bb4643ca7f1", {
    cluster: "us2",
    encrypted: true
  });

  window.socketId = null;
  pusher.connection.bind("connected", function() {
    window.socketId = pusher.connection.socket_id;
  });

  var channel = pusher.subscribe(`meal-${id}`);
  channel.bind("update", function(data) {
    console.log(data.message);

    if (store.billStore && store.billStore.bills) {
      store.clearBills();
    }
    if (store.residentStore && store.residentStore.residents) {
      store.clearResidents();
    }
    if (store.guestStore && store.guestStore.guests) {
      store.clearGuests();
    }

    store.loadDataAsync();
  });

  render(
    <Provider store={store}>
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
    </Provider>,
    document.getElementById("main")
  );
});
