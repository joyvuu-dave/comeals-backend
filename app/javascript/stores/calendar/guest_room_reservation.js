import { types, getParent } from "mobx-state-tree";
import axios from "axios";

const GuestRoomReservation = types
  .model("GuestRoomReservation", {
    title: "",
    start: "",
    url: "",
    description: ""
  })
  .views(self => ({
    get form() {
      return getParent(this, 2);
    }
  }))
  .actions(self => ({}));

export default GuestRoomReservation;
