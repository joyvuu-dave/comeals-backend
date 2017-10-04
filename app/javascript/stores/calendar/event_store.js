import { types, getParent } from "mobx-state-tree";
import Event from "./event";

const EventStore = types
  .model("EventStore", { bills: types.map(Event) })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default EventStore;
