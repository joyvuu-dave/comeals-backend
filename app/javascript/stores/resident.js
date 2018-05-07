import { types, getParent } from "mobx-state-tree";
import { v4 } from "uuid";
import axios from "axios";
import Cookie from "js-cookie";

const Resident = types
  .model("Resident", {
    id: types.identifier(types.number),
    meal_id: types.number,
    name: types.string,
    attending: false,
    attending_at: types.maybe(types.Date),
    late: false,
    vegetarian: false,
    can_cook: true,
    active: true
  })
  .views(self => ({
    get guests() {
      return Array.from(self.form.form.guestStore.guests.values()).filter(
        guest => guest.resident_id === self.id
      );
    },
    get guestsCount() {
      return self.guests.length;
    },
    get canRemoveGuest() {
      // Scenario #1: no guests
      if (self.guestsCount === 0) {
        return false;
      }

      // Scenario #2: guests, meal open
      if (self.guestsCount > 0 && !self.form.form.meal.closed) {
        return true;
      }

      // Scenario #3: guests, meal closed, guests added after meal closed
      if (
        self.guestsCount > 0 &&
        self.form.form.meal.closed &&
        self.guests.filter(
          guest => guest.created_at > self.form.form.meal.closed_at
        ).length > 0
      ) {
        return true;
      }

      // Scenario #4: guests, meal closed, guests added before meal closed
      if (
        self.guestsCount > 0 &&
        self.form.form.meal.closed &&
        Array.from(self.guests).filter(
          guest => guest.created_at <= self.form.form.meal.closed_at
        ).length > 0
      ) {
        return false;
      }
    },
    get canRemove() {
      // Scenario #1: not attending
      if (self.attending === false) {
        return false;
      }

      // Scenario #2: attending, meal open
      if (self.attending && !self.form.form.meal.closed) {
        return true;
      }

      // Scenario #3: attending, meal closed, added after meal closed
      if (
        self.attending &&
        self.form.form.meal.closed &&
        self.attending_at > self.form.form.meal.closed_at
      ) {
        return true;
      }

      // Scenario #4: guests, meal closed, added before meal closed
      if (
        self.guestsCount > 0 &&
        self.form.form.meal.closed &&
        self.attending_at <= self.form.form.meal.closed_at
      ) {
        return false;
      }
    },
    get form() {
      return getParent(self, 2);
    }
  }))
  .actions(self => ({
    setAttending(val) {
      self.attending = val;
      return val;
    },
    setAttendingAt(val) {
      self.attending_at = val;
      return val;
    },
    setLate(val) {
      self.late = val;
      return val;
    },
    toggleAttending(options = { late: false, toggleVeg: false }) {
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      // Scenario #1: Meal is closed, you're not attending
      //              there are no extras -- can't add yourself
      if (
        self.form.form.meal.closed &&
        !self.attending &&
        self.form.form.meal.extras < 1
      ) {
        return;
      }

      // Scenario #2: Meal is closed, you are attending -- can't remove yourself
      if (self.form.form.meal.closed && self.attending && !self.canRemove) {
        return;
      }

      const val = !self.attending;
      self.attending = val;

      // Toggle Late if Necessary
      if (options.late) {
        self.late = !self.late;
      }

      // Toggle Veg if Necessary
      if (options.toggleVeg) {
        self.vegetarian = !self.vegetarian;
      }

      const currentVeg = self.vegetarian;
      const currentLate = self.late;

      if (val) {
        self.form.form.meal.decrementExtras();
        axios({
          method: "post",
          url: `${host}api.comeals${topLevel}/api/v1/meals/${
            self.meal_id
          }/residents/${self.id}`,
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
          url: `${host}api.comeals${topLevel}/api/v1/meals/${
            self.meal_id
          }/residents/${self.id}`,
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
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      if (self.attending === false) {
        self.toggleAttending({ late: true });
        return;
      }

      const val = !self.late;
      self.late = val;

      axios({
        method: "patch",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${
          self.meal_id
        }/residents/${self.id}`,
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
          self.setLate(!val);

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
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      if (self.attending === false) {
        self.toggleAttending({ toggleVeg: true });
        return;
      }

      const val = !self.vegetarian;
      self.vegetarian = val;

      axios({
        method: "patch",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${
          self.meal_id
        }/residents/${self.id}`,
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
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      self.form.form.meal.decrementExtras();

      axios({
        method: "post",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${
          self.meal_id
        }/residents/${self.id}/guests`,
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
      console.log("This Resident Can Remove Guests: ", self.canRemoveGuest);

      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      if (!self.canRemoveGuest) {
        return false;
      }

      // Sort Guests
      const sortedGuests = Array.from(self.guests).sort((a, b) => {
        if (a.created_at > b.created_at) return -1;
        if (a.created_at < b.created_at) return 1;
        return 0;
      });

      // Grab Id of newest guest
      const guestId = sortedGuests[0].id;

      axios({
        method: "delete",
        url: `${host}api.comeals${topLevel}/api/v1/meals/${
          self.meal_id
        }/residents/${self.id}/guests/${guestId}`,
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
  }));

export default Resident;
