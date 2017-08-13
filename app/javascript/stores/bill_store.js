import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Bill from "./bill";

const BillStore = types.model("BillStore", {
  bills: types.map(Bill),
  get form() {
    return getParent(this);
  }
});

export default BillStore;
