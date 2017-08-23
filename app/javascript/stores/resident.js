import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Resident = types.model(
  "Resident",
  {
    id: types.identifier(types.number),
    meal_id: types.number,
    name: types.string,
    attending: false,
    attending_at: types.maybe(types.Date),
    late: false,
    vegetarian: false,
    get guests() {
      return this.form.form.guestStore.guests
        .values()
        .filter(guest => guest.resident_id === this.id);
    },
    get guestsCount() {
      return this.guests.length;
    },
    get canRemoveGuest() {
      // Scenario #1: no guests
      if (this.guestsCount === 0) {
        return false;
      }

      // Scenario #2: guests, meal open
      if (this.guestsCount > 0 && !this.form.form.meal.closed) {
        return true;
      }

      // Scenario #3: guests, meal closed, guests added after meal closed
      if (
        this.guestsCount > 0 &&
        this.form.form.meal.closed &&
        this.guests.filter(
          guest => guest.created_at > this.form.form.meal.closed_at
        ).length > 0
      ) {
        return true;
      }

      // Scenario #4: guests, meal closed, guests added before meal closed
      if (
        this.guestsCount > 0 &&
        this.form.form.meal.closed &&
        this.guests.filter(
          guest => guest.created_at <= this.form.form.meal.closed_at
        ).length > 0
      ) {
        return false;
      }
    },
    get canRemove() {
      // Scenario #1: not attending
      if (this.attending === false) {
        return false;
      }

      // Scenario #2: attending, meal open
      if (this.attending && !this.form.form.meal.closed) {
        return true;
      }

      // Scenario #3: attending, meal closed, added after meal closed
      if (
        this.attending &&
        this.form.form.meal.closed &&
        this.attending_at > this.form.form.meal.closed_at
      ) {
        return true;
      }

      // Scenario #4: guests, meal closed, added before meal closed
      if (
        this.guestsCount > 0 &&
        this.form.form.meal.closed &&
        this.attending_at <= this.form.form.meal.closed_at
      ) {
        return false;
      }
    },
    get form() {
      return getParent(this, 2);
    }
  },
  {
    setAttending(val) {
      this.attending = val;
      return val;
    },
    setAttendingAt(val) {
      this.attending_at = val;
      return val;
    },
    setLate(val) {
      this.late = val;
      return val;
    },
    toggleAttending(options = { late: false, toggleVeg: false }) {
      // Scenario #1: Meal is closed, you're not attending
      //              there are no extras -- can't add yourself
      if (
        this.form.form.meal.closed &&
        !this.attending &&
        this.form.form.meal.extras < 1
      ) {
        return;
      }

      // Scenario #2: Meal is closed, you are attending -- can't remove yourself
      if (this.form.form.meal.closed && this.attending && !this.canRemove) {
        return;
      }

      const val = !this.attending;
      this.attending = val;

      const self = this;

      // Toggle Late if Necessary
      if (options.late) {
        this.late = !this.late;
      }

      // Toggle Veg if Necessary
      if (options.toggleVeg) {
        this.vegetarian = !this.vegetarian;
      }

      const currentVeg = this.vegetarian;
      const currentLate = this.late;

      if (val) {
        self.form.form.meal.decrementExtras();
        axios({
          method: "post",
          url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
            .meal_id}/residents/${this.id}`,
          data: {
            socket_id: window.socketId,
            late: currentLate,
            vegetarian: currentVeg
          },
          withCredentials: true
        })
          .then(function(response) {
            if (response.status === 200) {
              console.log("Post - Success!", response.data);
              self.setAttendingAt(new Date());
            }
          })
          .catch(function(error) {
            console.log("Post - Fail!");
            self.setAttending(false);
            self.setAttendingAt(null);
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
              self.setLate(false);
              self.setAttendingAt(null);
            }
          })
          .catch(function(error) {
            console.log("Delete - Fail!");
            self.setAttending(true);
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
    toggleLate() {
      if (this.attending == false) {
        const self = this;
        this.toggleAttending({ late: true });
        return;
      }

      const val = !this.late;
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
    toggleVeg() {
      if (this.attending == false) {
        const self = this;
        this.toggleAttending({ toggleVeg: true });
        return;
      }

      const val = !this.vegetarian;
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
    addGuest(options = { vegetarian: false }) {
      this.form.form.meal.decrementExtras();

      const self = this;
      axios({
        method: "post",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}/guests`,
        data: {
          socket_id: window.socketId,
          vegetarian: options.vegetarian
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            console.log("Guests Post - Success!", response.data);
            const guest = response.data;
            guest.name = null;
            guest.created_at = new Date(guest.created_at);
            self.form.form.appendGuest(guest);
          }
        })
        .catch(function(error) {
          console.log("Guests Post - Fail!");
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
      console.log("This Resident Can Remove Guests: ", this.canRemoveGuest);

      if (!this.canRemoveGuest) {
        return false;
      }

      // Sort Guests
      const sortedGuests = this.guests.sort((a, b) => {
        if (a.created_at > b.created_at) return -1;
        if (a.created_at < b.created_at) return 1;
        return 0;
      });

      // Grab Id of newest guest
      const guestId = sortedGuests[0].id;

      const self = this;
      axios({
        method: "delete",
        url: `${window.host}api.comeals${window.topLevel}/api/v1/meals/${this
          .meal_id}/residents/${this.id}/guests/${guestId}`,
        data: {
          socket_id: window.socketId
        },
        withCredentials: true
      })
        .then(function(response) {
          if (response.status === 200) {
            self.form.form.guestStore.removeGuest(guestId);
            self.form.form.meal.incrementExtras();
            console.log("Guests Delete - Success!", response.data);
          }
        })
        .catch(function(error) {
          console.log("Guests Delete - Fail!");

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

export default Resident;
