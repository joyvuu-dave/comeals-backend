import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";

import ResidentsPasswordReset from "./password_reset";

class ResidentsLogin extends Component {
  constructor(props) {
    super(props);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`,
      pwResetVisible: false
    };
  }

  handlePasswordReset() {
    this.setState((prevState, props) => {
      return { pwResetVisible: !prevState.pwResetVisible };
    });
  }

  handleSubmit(values) {
    var myState = this.state;

    axios
      .post(
        `${myState.host}api.comeals${myState.topLevel}/api/v1/residents/token`,
        {
          email: values.email,
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          console.log("data", response.data);
          // set token cookie
          Cookie.set("token", response.data.token, {
            expires: 7300,
            domain: `.comeals${myState.topLevel}`
          });
          // set community_id cookie
          Cookie.set("community_id", response.data.community_id, {
            expires: 7300,
            domain: `.comeals${myState.topLevel}`
          });

          // set community_id cookie
          Cookie.set("resident_id", response.data.resident_id, {
            expires: 7300,
            domain: `.comeals${myState.topLevel}`
          });

          // set username cookie
          Cookie.set("username", response.data.username, {
            expires: 7300,
            domain: `.comeals${myState.topLevel}`
          });

          window.location.reload(true);
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
  }

  render() {
    return (
      <div>
        <LocalForm onSubmit={values => this.handleSubmit(values)}>
          <fieldset className="login-box">
            <legend>Resident Login</legend>
            <label className="w-80">
              <Control.text
                model=".email"
                placeholder="Email"
                autoCapitalize="none"
              />
            </label>
            <br />
            <label className="w-80">
              <Control.password
                type="password"
                model=".password"
                placeholder="Password"
              />
            </label>
          </fieldset>

          <button type="submit">Submit</button>
        </LocalForm>
        <br />
        <a
          className="button button-link"
          onClick={this.handlePasswordReset.bind(this)}
        >
          Reset your password
        </a>
        {this.state.pwResetVisible && <ResidentsPasswordReset />}
      </div>
    );
  }
}

export default ResidentsLogin;
