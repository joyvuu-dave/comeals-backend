import React, { Component } from "react";
import Cookie from "js-cookie";
import axios from "axios";

class WebcalLinks extends Component {
  constructor(props) {
    super(props);

    this.state = {
      topLevel: window.location.hostname.split(".")[2],
      host: `${window.location.protocol}//`,
      resident_id: Cookie.get("resident_id"),
      ready: false
    };
  }

  componentDidMount() {
    if (typeof this.state.resident_id === "undefined") {
      var self = this;
      axios
        .get(
          `${self.state.host}api.comeals.${
            self.state.topLevel
          }/api/v1/residents/id?token=${Cookie.get("token")}`
        )
        .then(function(response) {
          if (response.status === 200) {
            Cookie.set("resident_id", response.data, {
              expires: 7300,
              domain: `.comeals.${self.state.topLevel}`
            });

            self.setState({
              resident_id: response.data,
              ready: true
            });
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
    } else {
      this.setState({
        ready: true
      });
    }
  }

  render() {
    return (
      <div className="flex space-between w-100">
        <a
          href={`webcal://api.comeals.${
            this.state.topLevel
          }/api/v1/communities/${Cookie.get("community_id")}/ical.ics`}
        >
          Subscribe to All Meals
        </a>
        {this.state.ready && (
          <a
            href={`webcal://api.comeals.${
              this.state.topLevel
            }/api/v1/residents/${this.state.resident_id}/ical.ics`}
          >
            Subscribe to My Meals
          </a>
        )}
      </div>
    );
  }
}

export default WebcalLinks;
