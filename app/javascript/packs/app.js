import "../src/overrides.css";
import axios from "axios";
import Cookie from "js-cookie";

document.addEventListener("DOMContentLoaded", () => {
  (function checkVersion() {
    var topLevel = window.location.hostname.split(".")[2];

    axios
      .get(
        `${window.location.protocol}//api.comeals.${topLevel}/api/v1/version`
      )
      .then(function(response) {
        if (response.status === 200) {
          var clientVersion = response.data.version;
          var serverVersion = Cookie.get("version");

          if (typeof serverVersion === "undefined") {
            Cookie.set("version", clientVersion, {
              expires: 7300,
              domain: `.comeals.${topLevel}`
            });

            // update the ui
            var element = document.getElementById("version");
            element.innerHTML = `v${clientVersion}`;
          } else if (String(clientVersion) !== String(serverVersion)) {
            window.location.reload(true);
          }
        }
      })
      .catch(function(error) {
        if (error.response) {
          // The request was made and the server responded with a status code
          // that falls out of the range of 2xx
          const data = error.response.data;
          const status = error.response.status;
          const headers = error.response.headers;

          console.error("Unable to load version.");
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

    window.setTimeout(checkVersion, 1800000);
  })();
});
