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
      if (navigator.onLine) {
        console.log("coming back online...");
        if (store.meal && store.meal.id) {
          store.loadDataAsync();
        }
      }
    }

    window.addEventListener("online", updateOnlineStatus);
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
