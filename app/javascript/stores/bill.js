import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Resident from "./resident";

const Bill = types.model(
  "Bill",
  {
    id: types.identifier(),
    resident: types.maybe(types.reference(Resident)),
    amount: "",
    get resident_id() {
      return this.resident && this.resident.id ? this.resident.id : "";
    },
    get amountCents() {
      return Number.parseInt(Number(this.amount) * 100);
    },
    get amountIsValid() {
      return Number.isInteger(this.amountCents) && this.amountCents >= 0;
    }
  },
  {
    setResident(val) {
      if (val === "") {
        this.resident = null;
        return null;
      } else {
        this.resident = val;
        return this.resident;
      }
    },
    setAmount(val) {
      this.amount = val;
      return val;
    }
  }
);

export default Bill;
