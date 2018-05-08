import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";
import { types } from "mobx-state-tree";

import createBrowserHistory from "history/createBrowserHistory";
import { RouterModel, syncHistoryWithStore } from "mst-react-router";
import { Router } from "react-router";

import { CalendarStore } from "../../stores/calendar_store";

import Calendar from "../../components/calendar/show";
import { getCalendarInfo } from "../../helpers/helpers";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  var calendarInfo = getCalendarInfo(data.community_id, data.calendar_type);

  const browserHistory = createBrowserHistory();
  const routerModel = RouterModel.create();

  // Define root model type
  const Model = types.model({
    router: RouterModel
  });

  const routingStore = Model.create({ router: routerModel });

  const store = CalendarStore.create({
    userName: data.name,
    calendarName: calendarInfo.displayName,
    eventSources: calendarInfo.eventSources
  });

  window.store = store;

  const stores = {
    routingStore: routingStore,
    store: store
  };

  // Hook up router model to browser history object
  const history = syncHistoryWithStore(createBrowserHistory(), routerModel);

  render(
    <Provider {...stores}>
      <Router history={history}>
        <Calendar />
      </Router>
    </Provider>,
    document.getElementById("calendar")
  );
});
