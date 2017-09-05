import { types, getParent } from "mobx-state-tree";
import Resident from "./resident";

const Guest = types
  .model("Guest", {
    id: types.identifier(types.number),
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

export default Guest;
