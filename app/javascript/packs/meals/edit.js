import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";
import { types } from "mobx-state-tree";
import Pusher from "pusher-js";

import createBrowserHistory from "history/createBrowserHistory";
import { RouterModel, syncHistoryWithStore } from "mst-react-router";
import { Router } from "react-router";

import { DataStore } from "../../stores/data_store";
import MealsEdit from "../../components/meals/edit";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const id = parseInt(data.id);

  const browserHistory = createBrowserHistory();
  const routerModel = RouterModel.create();

  // Define root model type
  const Model = types.model({
    router: RouterModel
  });

  const routingStore = Model.create({ router: routerModel });

  const store = DataStore.create({
    meal: id,
    meals: [{ id: id }]
  });

  window.store = store;

  const stores = {
    routingStore: routingStore,
    store: store
  };

  // Hook up router model to browser history object
  const history = syncHistoryWithStore(createBrowserHistory(), routerModel);

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
    <Provider {...stores}>
      <Router history={history}>
        <MealsEdit />
      </Router>
    </Provider>,
    document.getElementById("main")
  );
});
