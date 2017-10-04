import { types, getParent } from "mobx-state-tree";
import Bill from "./rotation";

const RotationStore = types
  .model("RotationStore", { bills: types.map(Rotation) })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default RotationStore;
