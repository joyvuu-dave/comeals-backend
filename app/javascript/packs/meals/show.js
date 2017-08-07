import React from "react";
import ReactDOM from "react-dom";
import { Provider } from "mobx-react";

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
  const node = document.getElementById("meal-id");
  const data = JSON.parse(node.getAttribute("data"));
  const id = Number.parseInt(data.id);
  const date = new Date(data.date);
  const production = data.production;

  if (production) {
    window.host = "https://";
    window.topLevel = ".com";
  } else {
    window.host = "http://";
    window.topLevel = ".dev";
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

    store.loadDataAsync();
  });

  ReactDOM.render(
    <Provider store={store}>
      <div>
        <Header />
        <div className="container">
          <section style={styles.section}>
            <div className="wrapper">
              <ButtonBar />
              <DateBox />
              <MenuBox />
              <CooksBox />
              <InfoBox />
              <AttendeesBox />
            </div>
          </section>
          <footer style={styles.footer}>
            <h2 className="text-center text-muted">
              Made by{" "}
              <a href="https://github.com/joyvuu-dave" className="text-muted">
                David
              </a>
            </h2>
          </footer>
        </div>
      </div>
    </Provider>,
    document.getElementById("root")
  );
});

/* Flex container, centered content*/
const styles = {
  section: {
    margin: "1em 0 1em 0",
    minHeight: "var(--section-height)"
  },
  footer: {
    margin: "3rem 3rem 3rem 3rem"
  }
};
