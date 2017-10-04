import { types, getParent } from "mobx-state-tree";
import GuestRoomReservation from "./guest_room_reservation";

const GuestRoomReservationStore = types
  .model("GuestRoomReservationStore", {
    guest_room_reservations: types.map(GuestRoomReservation)
  })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default GuestRoomReservationStore;
