import React from "react";
import { render } from "react-dom";

import Calendar from "../../components/calendar/show";
import { getEventSources } from "../../helpers/helpers";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("site-data");
  const data = JSON.parse(node.getAttribute("data"));

  var eventSources = getEventSources(data.community_id);

  const node2 = document.getElementById("calendar-data");
  const data2 = JSON.parse(node2.getAttribute("data"));

  render(
    <Calendar
      calendarName={data2.displayName}
      eventSources={eventSources[data2.name]}
      userName={data.name}
    />,
    document.getElementById("calendar")
  );
});
