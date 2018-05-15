import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";
import Meal from "./meal";
import ResidentStore from "./resident_store";
import BillStore from "./bill_store";
import GuestStore from "./guest_store";
import EventSource from "./event_source";
import { RouterModel } from "mst-react-router";

export const DataStore = types
  .model("DataStore", {
    isLoading: true,
    editDescriptionMode: true,
    editBillsMode: true,
    meal: types.maybe(types.reference(Meal)),
    nextMeal: types.maybe(types.reference(Meal)),
    prevMeal: types.maybe(types.reference(Meal)),
    meals: types.optional(types.array(Meal), []),
    residentStore: types.optional(ResidentStore, {
      residents: {}
    }),
    billStore: types.optional(BillStore, {
      bills: {}
    }),
    guestStore: types.optional(GuestStore, {
      guests: {}
    }),
    router: RouterModel,
    calendarName: types.optional(types.string, ""),
    userName: types.optional(types.string, ""),
    eventSources: types.optional(types.array(EventSource), []),
    modalActive: false,
    modalName: types.maybe(types.string),
    modalIsChanging: false
  })
  .views(self => ({
    get id() {
      return self.meal.id;
    },
    get description() {
      return self.meal.description;
    },
    get residents() {
      return self.residentStore.residents;
    },
    get bills() {
      return self.billStore.bills;
    },
    get guests() {
      return self.guestStore.guests;
    },
    get guestsCount() {
      return self.guestStore.guests.size;
    },
    get mealResidentsCount() {
      return Array.from(self.residents.values()).filter(
        resident => resident.attending
      ).length;
    },
    get attendeesCount() {
      return self.guestsCount + self.mealResidentsCount;
    },
    get vegetarianCount() {
      const vegResidents = Array.from(self.residents.values()).filter(
        resident => resident.attending && resident.vegetarian
      ).length;

      const vegGuests = Array.from(self.guests.values()).filter(
        guest => guest.vegetarian
      ).length;

      return vegResidents + vegGuests;
    },
    get lateCount() {
      return Array.from(self.residents.values()).filter(
        resident => resident.late
      ).length;
    },
    get extras() {
      // Extras only show when the meal is closed
      if (!self.meal.closed) {
        return "n/a";
      }

      if (self.meal.closed && typeof self.meal.max === "number") {
        return self.meal.max - self.attendeesCount;
      } else {
        return "";
      }
    },
    get canAdd() {
      return (
        !self.meal.closed ||
        (self.meal.closed && self.extas === "") ||
        (self.meal.closed &&
          typeof self.extras === "number" &&
          self.extras >= 1)
      );
    }
  }))
  .actions(self => ({
    toggleEditDescriptionMode() {
      const isSaving = self.editDescriptionMode;
      self.editDescriptionMode = !self.editDescriptionMode;

      if (isSaving) {
        self.submitDescription();
      }
    },
    toggleEditBillsMode() {
      const isSaving = self.editBillsMode;
      self.editBillsMode = !self.editBillsMode;

      if (isSaving) {
        self.submitBills();
      }
    },
    setDescription(val) {
      self.meal.description = val;
      self.toggleEditDescriptionMode();
      self.toggleEditDescriptionMode();
      return self.meal.description;
    },
    toggleClosed() {
      const val = !self.meal.closed;
      self.meal.closed = val;

      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      axios({
        url: `${
          window.location.protocol
        }//api.comeals${topLevel}/api/v1/meals/${self.meal.id}/closed`,
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
          self.meal.toggleClosed();
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
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;
      var host = `${window.location.protocol}//`;

      Cookie.remove("token", { domain: `.comeals${topLevel}` });

      setTimeout(() => (window.location.href = `${host}comeals${topLevel}/`));
    },
    calendar() {
      //window.location.href = "/calendar";
      self.router.push("/calendar");
    },
    history() {
      window.open(`/meals/${self.id}/log`, "_blank", "noopener");
    },
    submitDescription() {
      let obj = {
        id: self.meal.id,
        description: self.meal.description,
        socket_id: window.socketId
      };

      console.log(obj);

      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      axios({
        method: "patch",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${
          self.meal.id
        }/description`,
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
      if (
        Array.from(self.bills.values()).some(
          bill => bill.amountIsValid === false
        )
      ) {
        self.editBillsMode = true;
        return;
      }

      // Format Bills
      let bills = Array.from(self.bills.values())
        .map(bill => bill.toJSON())
        .map(bill => {
          let obj = Object.assign({}, bill);

          // delete id
          delete obj["id"];

          // resident --> resident_id
          obj["resident_id"] = obj["resident"];
          delete obj["resident"];

          // amount --> amount_cents
          obj["amount_cents"] = parseInt(Number(obj["amount"]) * 100);
          delete obj["amount"];

          return obj;
        })
        .filter(bill => bill.resident_id !== null);

      let obj = {
        id: self.meal.id,
        bills: bills,
        socket_id: window.socketId
      };

      console.log(obj);

      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      axios({
        method: "patch",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${self.meal.id}/bills`,
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

          if (self.billStore && self.billStore.bills) {
            self.clearBills();
          }
          if (self.residentStore && self.residentStore.residents) {
            self.clearResidents();
          }
          if (self.guestStore && self.guestStore.guests) {
            self.clearGuests();
          }

          self.loadDataAsync();
        });
    },
    loadDataAsync(id) {
      var myId = id;
      if (typeof myId === "undefined") {
        console.log("myId undefined");
        if (self.meal === null) {
          console.log("meal undefined");
          var pathNameArray = self.router.location.pathname.split("/");
          myId = pathNameArray[pathNameArray.length - 2];
        } else {
          console.log("loading meal: " + self.meal.id);
          myId = self.meal.id;
        }
      }

      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      axios
        .get(`${host}api.comeals${topLevel}/api/v1/meals/${myId}/cooks`)
        .then(function(response) {
          if (response.status === 200) {
            self.loadData(self.meal, response.data);
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
    loadData(meal, data) {
      // Assign Meal Data
      const dateArray = data.date.split("-");
      const date = new Date(
        dateArray[0],
        Number(dateArray[1] - 1),
        Number(dateArray[2])
      );

      meal.date = date;
      meal.description = data.description;
      meal.closed = data.closed;
      meal.closed_at = new Date(data.closed_at);
      meal.reconciled = data.reconciled;
      meal.nextId = data.next_id;
      meal.prevId = data.prev_id;

      if (data.max === null) {
        meal.extras = null;
      } else {
        const residentsCount = data.residents.filter(
          resident => resident.attending
        ).length;

        const guestsCount = data.guests.length;
        meal.extras = data.max - (residentsCount + guestsCount);
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
        self.residentStore.residents.put(resident);
      });

      // Assign Guests
      data.guests.forEach(guest => {
        guest.created_at = new Date(guest.created_at);
        self.guestStore.guests.put(guest);
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
        self.billStore.bills.put(bill);
      });

      // Change loading state
      self.isLoading = false;
    },
    afterCreate() {
      var pathNameArray = window.location.pathname.split("/");

      if (pathNameArray[pathNameArray.length - 3] === "meals") {
        var myId = pathNameArray[pathNameArray.length - 2];

        self.meals.push({ id: Number(myId) });
        self.meal = myId;

        self.loadDataAsync(myId);
      } else {
        console.log("must be a calendar...");
      }
    },
    clearResidents() {
      self.residentStore.residents.clear();
    },
    clearBills() {
      self.billStore.bills.clear();
    },
    clearGuests() {
      self.guestStore.guests.clear();
    },
    appendGuest(obj) {
      self.guestStore.guests.put(obj);
    },
    addMeal(obj) {
      self.meals.push(obj);
    },
    switchMeals(obj) {
      if (
        typeof self.meals.find((item, index, array) => item.id === obj.id) ===
        "undefined"
      ) {
        self.addMeal(obj);
      }

      self.meal = obj.id;

      if (self.billStore && self.billStore.bills) {
        self.clearBills();
      }
      if (self.residentStore && self.residentStore.residents) {
        self.clearResidents();
      }
      if (self.guestStore && self.guestStore.guests) {
        self.clearGuests();
      }

      self.loadDataAsync();
    },
    goToPrevMeal() {
      self.isLoading = true;
      self.switchMeals({ id: self.meal.prevId });
    },
    goToNextMeal() {
      self.isLoading = true;
      self.switchMeals({ id: self.meal.nextId });
    },
    goToMeal(mealId) {
      self.isLoading = true;
      self.switchMeals({ id: Number.parseInt(mealId, 10) });
    },
    fetchPrev() {
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      var myId = self.meal.id;

      axios
        .get(`${host}api.comeals${topLevel}/api/v1/meals/${myId}/prev`)
        .then(function(response) {
          if (response.status === 200) {
            console.log("about to load prev data");
            self.loadData(self.prevMeal, response.data);
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
    setCalendarInfo(name, array) {
      self.modalIsChanging = false;
      self.calendarName = name;
      self.eventSources = array;
    },
    closeModal() {
      self.modalIsChanging = true;
      self.modalActive = false;
      self.modalName = null;
    },
    openModal(name) {
      self.modalIsChanging = true;
      self.modalName = name;
      self.modalActive = true;
    }
  }));
