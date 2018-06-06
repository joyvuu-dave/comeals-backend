import { types, getParent } from "mobx-state-tree";

const CalendarEvent = types
  .model("CalendarEvent", {
    id: types.identifier(),
    created_at: types.Date,
    meal_id: types.number,
    resident_id: types.number,
    name: types.maybe(types.string),
    vegetarian: false
  })
  .views(self => ({
    get form() {
      return getParent(self, 2);
    }
  }));

export default CalendarEvent;
