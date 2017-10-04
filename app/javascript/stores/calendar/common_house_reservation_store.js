import { types, getParent } from "mobx-state-tree";
import CommonHouseReservation from "./common_house_reservation";

const CommonHouseReservationStore = types
  .model("CommonHouseReservationStore", {
    ch_reservations: types.map(CommonHouseReservation)
  })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default CommonHouseReservationStore;
