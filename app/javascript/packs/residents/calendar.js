import React from "react";
import { render } from "react-dom";
import { Provider } from "mobx-react";

import createBrowserHistory from "history/createBrowserHistory";
import { RouterStore, syncHistoryWithStore } from "mobx-react-router";
import { Router } from "react-router";

import { CalendarStore } from "../../stores/calendar_store";

import Calendar from "../../components/calendar/show";
import { getCalendarInfo } from "../../helpers/helpers";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  var calendarInfo = getCalendarInfo(data.community_id, data.calendar_type);

  const browserHistory = createBrowserHistory();
  const routingStore = new RouterStore();

  const store = CalendarStore.create({
    userName: data.name,
    calendarName: calendarInfo.displayName,
    eventSources: calendarInfo.eventSources
  });

  window.store = store;

  const stores = {
    routing: routingStore,
    store: store
  };

  const history = syncHistoryWithStore(browserHistory, routingStore);

  render(
    <Provider {...stores}>
      <Router history={history}>
        <Calendar />
      </Router>
    </Provider>,
    document.getElementById("calendar")
  );
});
