import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Meal = types.model(
  "Meal",
  {
    id: types.identifier(types.number),
    description: "",
    extras: "",
    closed: false,
    date: types.Date,
    get max() {
      if (this.extras === "") {
        return null
      } else {
        return Number(this.extras) + this.form.attendeesCount
      }
    },
    get maxIsValid() {
      // Scenario #1: null
      if (this.max === null) {
        return true
      }

      // Scenario #2: not an integer
      if (!Number.isInteger(this.max)) {
        return false
      }

      // Scenario #3: less than attendees count
      if (Number.isInteger(this.max) && this.max < this.form.attendeesCount) {
        return false
      }

      // Scenario #4: greater than or equal to attendees count
      if (Number.isInteger(this.max) && this.max >= this.form.attendeesCount) {
        return true
      }
    },
    get form() {
      return getParent(this, 2);
    }
  },
  {
    setExtras(val) {
      if (Number.isInteger(Number.parseInt(Number(val)))) {
        this.extras = val
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
      return getParent(this);
    }
  },
  {
    setAttending(val) {
      this.attending = val;

      const self = this;

      if (val) {
        axios
          .post(
            `http://api.comeals.dev/api/v1/meals/${this
              .meal_id}/residents/${this.id}`
          )
          .then(function(response) {
            if (response.status === 200) {
              console.log("Post - Success!", response.data);
            }
          })
          .catch(function(error) {
            console.log("Post - Fail!");
            this.attending = false;

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
        axios
          .delete(
            `http://api.comeals.dev/api/v1/meals/${this
              .meal_id}/residents/${this.id}`
          )
          .then(function(response) {
            if (response.status === 200) {
              console.log("Delete - Success!", response.data);
            }
          })
          .catch(function(error) {
            console.log("Delete - Fail!");
            self.attending = true;
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

      const self = this
      axios.patch(`http://api.comeals.dev/api/v1/meals/${this.meal_id}/residents/${this.id}`, {late: val})
      .then(function (response) {
        if(response.status === 200) {
          console.log('Late click - Success!', response.data)
        }
      })
      .catch(function (error) {
        console.log('Late click - Fail!')
        self.late = !val

        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data
          const status = error.response.status
          const headers = error.response.headers

          window.alert(data.message)
        } else if (error.request) {
          // The request was made but no response was received
          // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
          // http.ClientRequest in node.js
          const request = error.request
        } else {
          // Something happened in setting up the request that triggered an Error
          const message = error.message
        }
        const config = error.config
      })
    },
    setVegetarian(val) {
      this.vegetarian = val;

      const self = this
      axios.patch(`http://api.comeals.dev/api/v1/meals/${this.meal_id}/residents/${this.id}`, {vegetarian: val})
      .then(function (response) {
        if(response.status === 200) {
          console.log('Veg click - Success!', response.data)
        }
      })
      .catch(function (error) {
        console.log('Veg click - Fail!')
        self.vegetarian = !val

        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data
          const status = error.response.status
          const headers = error.response.headers

          window.alert(data.message)
        } else if (error.request) {
          // The request was made but no response was received
          // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
          // http.ClientRequest in node.js
          const request = error.request
        } else {
          // Something happened in setting up the request that triggered an Error
          const message = error.message
        }
        const config = error.config
      })
    },
    addGuest() {
      this.guests = this.guests + 1

      const self = this
      axios.post(`http://api.comeals.dev/api/v1/meals/${this.meal_id}/residents/${this.id}/guests`)
      .then(function (response) {
        if(response.status === 200) {
          console.log('Guests Post - Success!', response.data)
        }
      })
      .catch(function (error) {
        console.log('Guests Post - Fail!')
        self.guests = self.guests - 1

        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data
          const status = error.response.status
          const headers = error.response.headers

          window.alert(data.message)
        } else if (error.request) {
          // The request was made but no response was received
          // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
          // http.ClientRequest in node.js
          const request = error.request
        } else {
          // Something happened in setting up the request that triggered an Error
          const message = error.message
        }
        const config = error.config
      })
    },
    removeGuest() {
      this.guests = this.guests - 1;

      const self = this;
      axios.delete(`http://api.comeals.dev/api/v1/meals/${this.meal_id}/residents/${this.id}/guests`)
      .then(function (response) {
        if(response.status === 200) {
          console.log('Guests Delete - Success!', response.data)
        }
      })
      .catch(function (error) {
        console.log('Guests Delete - Fail!')
        self.guests = self.guests - 1;

        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data
          const status = error.response.status
          const headers = error.response.headers

          window.alert(data.message)
        } else if (error.request) {
          // The request was made but no response was received
          // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
          // http.ClientRequest in node.js
          const request = error.request
        } else {
          // Something happened in setting up the request that triggered an Error
          const message = error.message
        }
        const config = error.config
      })
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
      return this.residents
        .values()
        .filter(resident => resident.attending).length;
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
      return this.attendeesCount - this.vegetarianCount
    },
    get lateCount() {
      return this.residents
        .values()
        .filter(resident => resident.late).length;
    },
    get extras() {
      // Extras only show when the meal is closed
      if (!this.meal.closed) {
        return 'n/a'
      }

      if (this.meal.closed && typeof this.meal.max === 'number') {
        return this.meal.max - this.attendeesCount
      } else {
        return ''
      }
    },
    get canAdd() {
      return (!this.meal.closed) ||
             (this.meal.closed && this.extas === '') ||
             (this.meal.closed && typeof this.extras === 'number' && this.extras >= 1)
    }
  },
  {
    setDescription(val) {
      this.meal.description = val;
      return this.meal.description;
    },
    setClosed(val) {
      this.meal.closed = val;
      return val;
    },
    logout() {
      Cookie.remove("token", { domain: ".comeals.dev" });
      window.location.href = "/";
    },
    submit() {
      // Check for errors with bills
      if (this.bills.values().some(bill => bill.amountIsValid === false)) {
        window.alert("Fix bills before submitting.");
        return;
      }

      // Check for errors with extras
      if (this.meal.maxIsValid === false) {
        window.alert("Fix extras value before submitting.");
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
        description: this.meal.description,
        max: this.meal.max,
        closed: this.meal.closed,
        bills: bills
      };

      console.log(obj);

      const self = this;
      axios
        .patch(`http://api.comeals.dev/api/v1/meals/${self.meal.id}`, obj)
        .then(function(response) {
          if (response.status === 200) {
            console.log(response.data);
            window.alert("Meal has been updated!");
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
        .get(`http://api.comeals.dev/api/v1/meals/${self.meal.id}/cooks`)
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
        this.meal.extras = ''
      } else {
        //const residents_count = data.residents
        this.meal.extras = 99
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
    }
  }
);
