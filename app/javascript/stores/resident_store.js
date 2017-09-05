import { types, getParent } from "mobx-state-tree";
import Resident from "./resident";

const ResidentStore = types
  .model("ResidentStore", { residents: types.map(Resident) })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default ResidentStore;
