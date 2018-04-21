import { types, getParent } from "mobx-state-tree";
import Guest from "./guest";

const GuestStore = types
  .model("GuestStore", {
    guests: types.map(Guest)
  })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }))
  .actions(self => ({
    removeGuest(id) {
      self.guests = Object.assign({}, self.guests.delete(id));
    }
  }));

export default GuestStore;
