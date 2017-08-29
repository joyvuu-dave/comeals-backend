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
    },
    get form() {
      return getParent(this, 2);
    }
  },
  {
    setResident(val) {
      if (val === "") {
        this.resident = null;
        this.form.form.toggleEditBillsMode();
        this.form.form.toggleEditBillsMode();
        return null;
      } else {
        this.resident = val;
        this.form.form.toggleEditBillsMode();
        this.form.form.toggleEditBillsMode();
        return this.resident;
      }
    },
    setAmount(val) {
      this.amount = val;
      this.form.form.toggleEditBillsMode();
      this.form.form.toggleEditBillsMode();
      return val;
    }
  }
);

export default Bill;
