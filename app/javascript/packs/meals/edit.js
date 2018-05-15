import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";
import { types } from "mobx-state-tree";
import Pusher from "pusher-js";

import createBrowserHistory from "history/createBrowserHistory";
import { RouterModel, syncHistoryWithStore } from "mst-react-router";
import { Router, Route } from "react-router";

import { DataStore } from "../../stores/data_store";
import MealsEdit from "../../components/meals/edit";
import Calendar from "../../components/calendar/show";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));
  const id = parseInt(data.id);

  const routerInstance = RouterModel.create();
  const store = DataStore.create({
    router: routerInstance
  });

  window.store = store;

  // Hook up router model to browser history object
  const history = syncHistoryWithStore(createBrowserHistory(), routerInstance);

  // Listen for changes to the current location.
  const unlisten = history.listen((location, action) => {
    // location is an object like window.location
    console.log(action, location.pathname, location.state);
  });

  var pusher = new Pusher("8affd7213bb4643ca7f1", {
    cluster: "us2",
    encrypted: true
  });

  // TODO: move to mobx-state-tree
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
      <Router history={history}>
        <div>
          <Route path="/calendar" component={Calendar} />
          <Route path="/meals" component={MealsEdit} />
        </div>
      </Router>
    </Provider>,
    document.getElementById("main")
  );
});
