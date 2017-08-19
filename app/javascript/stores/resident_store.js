import { types, getParent } from "mobx-state-tree";
import Resident from "./resident";

const ResidentStore = types.model("ResidentStore", {
  residents: types.map(Resident),
  get form() {
    return getParent(this);
  }
});

export default ResidentStore;
