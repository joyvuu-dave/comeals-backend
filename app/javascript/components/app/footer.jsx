import React, { Component } from "react";
import axios from "axios";

class Footer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      version: "",
      ready: false
    };
  }

  componentDidMount() {
    var host = `${window.location.protocol}//`;
    var topLevel = window.location.hostname.split(".");
    topLevel = `.${topLevel[topLevel.length - 1]}`;

    var self = this;
    axios
      .get(`${host}api.comeals${topLevel}/api/v1/version`)
      .then(function(response) {
        if (response.status === 200) {
          self.setState({
            version: `v${response.data.version}`,
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

  render() {
    return (
      <footer>
        <h4 className="text-center text-secondary">
          Created by{" "}
          <a
            href="https://github.com/joyvuu-dave/comeals-rewrite"
            target="_blank"
            rel="noopener"
            className="text-secondary"
          >
            David
          </a>{" "}
          <span id="version" className="text-small">
            {this.state.version}
          </span>
        </h4>
      </footer>
    );
  }
}

export default Footer;
