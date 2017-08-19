import { types, getParent } from "mobx-state-tree";
import Guest from "./guest";

const GuestStore = types.model("GuestStore", {
  guests: types.map(Guest),
  get form() {
    return getParent(this);
  }
});

export default GuestStore;
