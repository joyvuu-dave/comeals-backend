import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";

import createBrowserHistory from "history/createBrowserHistory";
import { RouterModel, syncHistoryWithStore } from "mst-react-router";
import { Router, Route } from "react-router";

import { DataStore } from "../../stores/data_store";
import MealsEdit from "../../components/meals/edit";
import Calendar from "../../components/calendar/show";

import ScrollToTop from "../../components/app/scroll_to_top";

document.addEventListener("DOMContentLoaded", () => {
  const routerInstance = RouterModel.create();
  const store = DataStore.create({
    router: routerInstance
  });

  // Hook up router model to browser history object
  const history = syncHistoryWithStore(createBrowserHistory(), routerInstance);

  render(
    <Provider store={store}>
      <Router history={history}>
        <ScrollToTop>
          <Route path="/calendar/:type" component={Calendar} />
          <Route path="/meals/:id/edit" component={MealsEdit} />
        </ScrollToTop>
      </Router>
    </Provider>,
    document.getElementById("main")
  );
});
