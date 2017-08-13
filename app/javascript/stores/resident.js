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
    late: false,
    vegetarian: false,
    guests: 0,
    get form() {
      return getParent(this, 2);
    }
  },
  {
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
      if (this.form.form.meal.closed && this.attending) {
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

export default Resident;
