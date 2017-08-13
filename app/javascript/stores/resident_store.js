import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Resident from "./resident";

const ResidentStore = types.model("ResidentStore", {
  residents: types.map(Resident),
  get form() {
    return getParent(this);
  }
});

export default ResidentStore;
