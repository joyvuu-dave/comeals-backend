import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";

import {
  BrowserRouter as Router,
  Route,
  Switch,
  Redirect
} from "react-router-dom";

import { DataStore } from "../../stores/data_store";
import MealsEdit from "../../components/meals/edit";
import Calendar from "../../components/calendar/show";

import ScrollToTop from "../../components/app/scroll_to_top";

document.addEventListener("DOMContentLoaded", () => {
  const store = DataStore.create();

  window.addEventListener("load", function() {
    function updateOnlineStatus(event) {
      var status = document.getElementById("status");
      var condition = navigator.onLine ? "online" : "offline";
      status.className = condition;
      status.innerHTML = condition.toUpperCase();

      if (navigator.onLine) {
        console.log(`back online at ${new Date().toLocaleTimeString()}`);
        if (store.meal && store.meal.id) {
          store.loadDataAsync();
        }
        store.loadMonthAsync();
      } else {
        console.log(`offline at ${new Date().toLocaleTimeString()}`);
      }
    }

    window.addEventListener("online", updateOnlineStatus);
    window.addEventListener("offline", updateOnlineStatus);
  });

  render(
    <Provider store={store}>
      <Router>
        <ScrollToTop>
          <Switch>
            <Route
              exact
              strict
              path="/:url*"
              render={props => <Redirect to={`${props.location.pathname}/`} />}
            />
            <Route
              path="/calendar/:type/:date/:modal?/:view?/:id?"
              component={Calendar}
            />
            <Route path="/meals/:id/edit/:history?" component={MealsEdit} />
          </Switch>
        </ScrollToTop>
      </Router>
    </Provider>,
    document.getElementById("main")
  );
});
