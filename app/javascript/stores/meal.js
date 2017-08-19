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
    closed_at: types.maybe(types.Date),
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

export default Meal;
