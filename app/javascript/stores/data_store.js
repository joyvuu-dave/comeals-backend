import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Meal = types.model(
  "Meal",
  {
    id: types.identifier(types.number),
    description: "",
    extras: types.maybe(types.number),
    closed: false,
    date: types.Date,
    get max() {
      if (this.extras === null) {
        return null;
      } else {
        return Number(this.extras) + this.form.attendeesCount;
      }
    },
    get form() {
      return getParent(this, 2);
    }
  },
  {
    resetExtras() {
      this.extras = null;
      console.log("Extras reset to null.");
      return null;
    },
    setExtras(val) {
      const previousExtras = this.extras;
      const self = this;

      // Scenario #1: empty string
      if (val === null) {
        this.extras = null;

        axios({
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
            .id}/max`,
          method: "patch",
          data: {
            max: null,
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Patch Extras - Success!", response.data);
            }

            return null; // return new value of extras as feedback when running function from console
          })
          .catch(function(error) {
            console.log("Patch Extras - Fail!");
            self.extras = previousExtras;

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

            return previousExtras; // return old value of extras as feedback when running function from console
          });
      }

      // Scenario #2: positive integer
      const num = Number.parseInt(Number(val));
      if (Number.isInteger(num) && num >= 0) {
        this.extras = num;

        axios({
          method: "patch",
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
            .id}/max`,
          data: {
            max: self.max,
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Patch Extras - Success!", response.data);
            }

            return num; // return new value of extras as feedback when running function from console
          })
          .catch(function(error) {
            console.log("Patch Extras - Fail!");
            self.extras = previousExtras;

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

            return previousExtras; // return old value of extras as feedback when running function from console
          });
      }
    },
    incrementExtras() {
      if (this.extras === null) {
        return;
      }

      const num = Number.parseInt(Number(this.extras));
      if (Number.isInteger(num)) {
        const temp = num + 1;
        this.extras = temp;
      }
    },
    decrementExtras() {
      if (this.extras === null) {
        return;
      }

      const num = Number.parseInt(Number(this.extras));
      if (Number.isInteger(num)) {
        const temp = num - 1;
        this.extras = temp;
      }
    }
  }
);

const Resident = types.model(
  "Resident",
  {
    id: types.identifier(types.number),
    meal_id: types.number,
    name: types.string,
    attending: false,
    late: false,
    vegetarian: false,
    guests: 0,
    get form() {
      return getParent(this, 2);
    }
  },
  {
    toggleAttending() {
      const val = !this.attending;
      this.attending = val;

      const self = this;

      if (val) {
        self.form.form.meal.decrementExtras();
        axios({
          method: "post",
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
            .meal_id}/residents/${this.id}`,
          data: {
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Post - Success!", response.data);
            }
          })
          .catch(function(error) {
            console.log("Post - Fail!");
            self.attending = false;
            self.form.form.meal.incrementExtras();

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
      } else {
        self.form.form.meal.incrementExtras();
        axios({
          method: "delete",
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
            .meal_id}/residents/${this.id}`,
          data: {
            socket_id: window.socketId
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Delete - Success!", response.data);
            }
          })
          .catch(function(error) {
            console.log("Delete - Fail!");
            self.attending = true;
            self.form.form.meal.decrementExtras();

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
      }
    },
    setLate(val) {
      this.late = val;

      const self = this;
      axios({
        method: "patch",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}`,
        data: {
          late: val,
          socket_id: window.socketId
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log("Late click - Success!", response.data);
          }
        })
        .catch(function(error) {
          console.log("Late click - Fail!");
          self.late = !val;

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
    setVegetarian(val) {
      this.vegetarian = val;

      const self = this;
      axios({
        method: "patch",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}`,
        data: {
          vegetarian: val,
          socket_id: window.socketId
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log("Veg click - Success!", response.data);
          }
        })
        .catch(function(error) {
          console.log("Veg click - Fail!");
          self.vegetarian = !val;

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
    addGuest() {
      this.guests = this.guests + 1;
      this.form.form.meal.decrementExtras();

      const self = this;
      axios({
        method: "post",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}/guests`,
        data: {
          socket_id: window.socketId
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log("Guests Post - Success!", response.data);
          }
        })
        .catch(function(error) {
          console.log("Guests Post - Fail!");
          self.guests = self.guests - 1;
          self.form.form.meal.incrementExtras();

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
    removeGuest() {
      this.guests = this.guests - 1;
      this.form.form.meal.incrementExtras();

      const self = this;
      axios({
        method: "delete",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}/guests`,
        data: {
          socket_id: window.socketId
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log("Guests Delete - Success!", response.data);
          }
        })
        .catch(function(error) {
          console.log("Guests Delete - Fail!");
          self.guests = self.guests - 1;
          self.form.form.meal.decrementExtras();

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
    }
  }
);

const ResidentStore = types.model("ResidentStore", {
  residents: types.map(Resident),
  get form() {
    return getParent(this);
  }
});

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

const BillStore = types.model("BillStore", {
  bills: types.map(Bill),
  get form() {
    return getParent(this);
  }
});

export const DataStore = types.model(
  "DataStore",
  {
    isLoading: true,
    editDescriptionMode: false,
    editBillsMode: false,
    meal: types.maybe(types.reference(Meal)),
    meals: types.array(Meal),
    residentStore: types.optional(ResidentStore, {
      residents: {}
    }),
    billStore: types.optional(BillStore, {
      bills: {}
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
    get guestsCount() {
      return this.residents
        .values()
        .map(resident => resident.guests)
        .reduce(function(sum, value) {
          return sum + value;
        }, 0);
    },
    get mealResidentsCount() {
      return this.residents.values().filter(resident => resident.attending)
        .length;
    },
    get attendeesCount() {
      return this.guestsCount + this.mealResidentsCount;
    },
    get vegetarianCount() {
      return this.residents
        .values()
        .filter(resident => resident.attending && resident.vegetarian).length;
    },
    get omnivoreCount() {
      return this.attendeesCount - this.vegetarianCount;
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
      Cookie.remove("token", { domain: ".comeals.dev" });
      window.location.href = "/";
    },
    calendar() {
      window.location.href = "/calendar";
    },
    history() {
      window.open(`/meals/${this.id}/log`, "_blank");
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
        window.alert("Fix bills before submitting.");
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
      if (data.max === null) {
        this.meal.extras = null;
      } else {
        const residents_count = data.residents.filter(
          resident => resident.attending
        ).length;
        const guests_count = data.residents
          .map(resident => resident.guests)
          .reduce(function(sum, value) {
            return sum + value;
          }, 0);
        this.meal.extras = data.max - (residents_count + guests_count);
      }

      // Assign Residents
      data.residents.forEach(resident => {
        this.residentStore.residents.put(resident);
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
    }
  }
);
