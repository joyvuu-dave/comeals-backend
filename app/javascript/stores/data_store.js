import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Meal from "./meal";
import ResidentStore from "./resident_store";
import BillStore from "./bill_store";
import GuestStore from "./guest_store";

export const DataStore = types.model(
  "DataStore",
  {
    isLoading: true,
    editDescriptionMode: true,
    editBillsMode: true,
    meal: types.maybe(types.reference(Meal)),
    meals: types.array(Meal),
    residentStore: types.optional(ResidentStore, {
      residents: {}
    }),
    billStore: types.optional(BillStore, {
      bills: {}
    }),
    guestStore: types.optional(GuestStore, {
      guests: {}
    }),
    get id() {
      return this.meal.id;
    },
    get description() {
      return this.meal.description;
    },
    get residents() {
      return this.residentStore.residents;
    },
    get bills() {
      return this.billStore.bills;
    },
    get guests() {
      return this.guestStore.guests;
    },
    get guestsCount() {
      return this.guestStore.guests.size;
    },
    get mealResidentsCount() {
      return this.residents.values().filter(resident => resident.attending)
        .length;
    },
    get attendeesCount() {
      return this.guestsCount + this.mealResidentsCount;
    },
    get vegetarianCount() {
      const vegResidents = this.residents
        .values()
        .filter(resident => resident.attending && resident.vegetarian).length;

      const vegGuests = this.guests.values().map(guest => guest.vegetarian)
        .length;

      return vegResidents + vegGuests;
    },
    get lateCount() {
      return this.residents.values().filter(resident => resident.late).length;
    },
    get extras() {
      // Extras only show when the meal is closed
      if (!this.meal.closed) {
        return "n/a";
      }

      if (this.meal.closed && typeof this.meal.max === "number") {
        return this.meal.max - this.attendeesCount;
      } else {
        return "";
      }
    },
    get canAdd() {
      return (
        !this.meal.closed ||
        (this.meal.closed && this.extas === "") ||
        (this.meal.closed &&
          typeof this.extras === "number" &&
          this.extras >= 1)
      );
    }
  },
  {
    toggleEditDescriptionMode() {
      const isSaving = this.editDescriptionMode;
      this.editDescriptionMode = !this.editDescriptionMode;

      if (isSaving) {
        this.submitDescription();
      }
    },
    toggleEditBillsMode() {
      const isSaving = this.editBillsMode;
      this.editBillsMode = !this.editBillsMode;

      if (isSaving) {
        this.submitBills();
      }
    },
    setDescription(val) {
      this.meal.description = val;
      this.toggleEditDescriptionMode();
      this.toggleEditDescriptionMode();
      return this.meal.description;
    },
    toggleClosed() {
      const val = !this.meal.closed;
      this.meal.closed = val;

      const self = this;

      axios({
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self
          .meal.id}/closed`,
        method: "patch",
        withCredentials: true,
        data: {
          closed: val,
          socket_id: window.socketId
        }
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log(response.data);

            // If meal has been opened, re-set extras value
            if (val === false) {
              self.meal.resetExtras();
              self.meal.resetClosedAt();
            } else {
              self.meal.setClosedAt();
            }
          }
        })
        .catch(function(error) {
          self.meal.closed = !val;
          console.log("Meal closed patch - Fail!");

          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            const data = error.response.data;
            const status = error.response.status;
            const headers = error.response.headers;

            window.alert(data.message);
          } else if (error.request) {
            // The request was made but no response was received
            // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
            // http.ClientRequest in node.js
            const request = error.request;
            window.alert("Error: no response received from server.");
          } else {
            // Something happened in setting up the request that triggered an Error
            const message = error.message;
            window.alert("Error: could not submit form.");
          }
          const config = error.config;
        });
    },
    logout() {
      Cookie.remove("token", { domain: `.comeals${window.topLevel}` });
      setTimeout(
        () =>
          (window.location.href = `${window.host}comeals${window.topLevel}/`)
      );
    },
    calendar() {
      window.location.href = "/calendar";
    },
    history() {
      window.open(`/meals/${this.id}/log`, "_blank");
    },
    previousMeal() {
      window.location.href = `/meals/${this.id}/previous`;
    },
    nextMeal() {
      window.location.href = `/meals/${this.id}/next`;
    },
    submitDescription() {
      let obj = {
        id: this.meal.id,
        description: this.meal.description,
        socket_id: window.socketId
      };

      console.log(obj);

      const self = this;
      axios({
        method: "patch",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self
          .meal.id}/description`,
        data: obj,
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log(response.data);
          }
        })
        .catch(function(error) {
          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            const data = error.response.data;
            const status = error.response.status;
            const headers = error.response.headers;

            window.alert(data.message);
          } else if (error.request) {
            // The request was made but no response was received
            // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
            // http.ClientRequest in node.js
            const request = error.request;
            window.alert("Error: no response received from server.");
          } else {
            // Something happened in setting up the request that triggered an Error
            const message = error.message;
            window.alert("Error: could not submit form.");
          }
          const config = error.config;
        });
    },
    submitBills() {
      // Check for errors with bills
      if (this.bills.values().some(bill => bill.amountIsValid === false)) {
        this.editBillsMode = true;
        return;
      }

      // Format Bills
      let bills = this.bills
        .values()
        .map(bill => bill.toJSON())
        .map(bill => {
          let obj = Object.assign({}, bill);

          // delete id
          delete obj["id"];

          // resident --> resident_id
          obj["resident_id"] = obj["resident"];
          delete obj["resident"];

          // amount --> amount_cents
          obj["amount_cents"] = Number.parseInt(Number(obj["amount"]) * 100);
          delete obj["amount"];

          return obj;
        })
        .filter(bill => bill.resident_id !== null);

      let obj = {
        id: this.meal.id,
        bills: bills,
        socket_id: window.socketId
      };

      console.log(obj);

      const self = this;
      axios({
        method: "patch",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self
          .meal.id}/bills`,
        data: obj,
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log(response.data);
          }
        })
        .catch(function(error) {
          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            const data = error.response.data;
            const status = error.response.status;
            const headers = error.response.headers;

            window.alert(data.message);
          } else if (error.request) {
            // The request was made but no response was received
            // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
            // http.ClientRequest in node.js
            const request = error.request;
            window.alert("Error: no response received from server.");
          } else {
            // Something happened in setting up the request that triggered an Error
            const message = error.message;
            window.alert("Error: could not submit form.");
          }
          const config = error.config;
        });
    },
    loadDataAsync() {
      const self = this;
      axios
        .get(
          `${window.host}api.comeals${window.topLevel}/api/v1/meals/${self.meal
            .id}/cooks`
        )
        .then(function(response) {
          if (response.status === 200) {
            window.data = response.data;
            self.loadData(response.data);
          }
        })
        .catch(function(error) {
          if (error.response) {
            // The request was made and the server responded with a status code
            // that falls out of the range of 2xx
            const data = error.response.data;
            const status = error.response.status;
            const headers = error.response.headers;

            window.alert(data.message);
          } else if (error.request) {
            // The request was made but no response was received
            // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
            // http.ClientRequest in node.js
            const request = error.request;
          } else {
            // Something happened in setting up the request that triggered an Error
            const message = error.message;
          }
          const config = error.config;
        });
    },
    loadData(data) {
      // Assign Meal Data
      this.meal.description = data.description;
      this.meal.closed = data.closed;
      this.meal.closed_at = new Date(data.closed_at);
      this.meal.reconciled = data.reconciled;

      if (data.max === null) {
        this.meal.extras = null;
      } else {
        const residentsCount = data.residents.filter(
          resident => resident.attending
        ).length;

        const guestsCount = data.guests.length;
        this.meal.extras = data.max - (residentsCount + guestsCount);
      }

      let residents = data.residents.sort((a, b) => {
        if (a.name < b.name) return -1;
        if (a.name > b.name) return 1;
        return 0;
      });

      // Assign Residents
      residents.forEach(resident => {
        if (resident.attending_at !== null)
          resident.attending_at = new Date(resident.attending_at);
        this.residentStore.residents.put(resident);
      });

      // Assign Guests
      data.guests.forEach(guest => {
        guest.created_at = new Date(guest.created_at);
        this.guestStore.guests.put(guest);
      });

      // Assign Bills
      let bills = data.bills;

      // Rename resident_id --> resident
      bills = bills.map(bill => {
        bill["resident"] = bill["resident_id"];
        delete bill["resident_id"];
        return bill;
      });

      // Convert amount_cents --> amount
      bills = bills.map(bill => {
        bill["amount"] =
          bill["amount_cents"] === 0
            ? ""
            : (bill["amount_cents"] / 100).toFixed(2);
        delete bill["amount_cents"];
        return bill;
      });

      // Determine # of blank bills needed
      const extra = Math.max(3 - bills.length, 0);

      // Create array for iterating
      const array = Array(extra).fill();

      // Create blanks bills
      array.forEach(() => bills.push([]));

      // Assign ids to bills
      bills = bills.map(obj => Object.assign({ id: v4() }, obj));

      // Put bills into BillStore
      bills.forEach(bill => {
        this.billStore.bills.put(bill);
      });

      // Change loading state
      this.isLoading = false;
    },
    afterCreate() {
      this.loadDataAsync();
    },
    clearResidents() {
      this.residentStore.residents.clear();
    },
    clearBills() {
      this.billStore.bills.clear();
    },
    appendGuest(obj) {
      this.guestStore.guests.put(obj);
    }
  }
);
