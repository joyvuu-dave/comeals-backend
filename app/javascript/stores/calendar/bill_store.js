import { types, getParent } from "mobx-state-tree";
import Bill from "./bill";

const BillStore = types
  .model("BillStore", { bills: types.map(Bill) })
  .views(self => ({
    get form() {
      return getParent(self);
    }
  }));

export default BillStore;
