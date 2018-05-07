import { types } from "mobx-state-tree";
import EventSource from "./event_source";

export const CalendarStore = types
  .model("CalendarStore", {
    calendarName: types.string,
    userName: types.string,
    eventSources: types.array(EventSource)
  })
  .actions(self => ({
    setCalendarName(name) {
      self.calendarName = name;
    },
    setEventSources(array) {
      self.eventSources = array;
    }
  }));
