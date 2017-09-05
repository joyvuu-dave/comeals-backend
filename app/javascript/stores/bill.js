import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Resident from "./resident";

const Bill = types
  .model("Bill", {
    id: types.identifier(),
    resident: types.maybe(types.reference(Resident)),
    amount: ""
  })
  .views(self => ({
    get resident_id() {
      return self.resident && self.resident.id ? self.resident.id : "";
    },
    get amountCents() {
      return parseInt(Number(self.amount) * 100);
    },
    get amountIsValid() {
      return Number.isInteger(self.amountCents) && self.amountCents >= 0;
    },
    get form() {
      return getParent(this, 2);
    }
  }))
  .actions(self => ({
    setResident(val) {
      if (val === "") {
        self.resident = null;
        self.form.form.toggleEditBillsMode();
        self.form.form.toggleEditBillsMode();
        return null;
      } else {
        self.resident = val;
        self.form.form.toggleEditBillsMode();
        self.form.form.toggleEditBillsMode();
        return self.resident;
      }
    },
    setAmount(val) {
      self.amount = val;
      self.form.form.toggleEditBillsMode();
      self.form.form.toggleEditBillsMode();
      return val;
    }
  }));

export default Bill;
