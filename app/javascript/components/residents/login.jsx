import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";

class ResidentsLogin extends Component {
  constructor(props) {
    super(props);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`
    };
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
          Cookie.set("token", response.data.token, {
            expires: 7300,
            domain: `.comeals${myState.topLevel}`
          });
          var newUrl = `${myState.host}${response.data.slug}.comeals${
            myState.topLevel
          }/calendar`;
          console.log("newUrl", newUrl);
          window.location.href = newUrl;
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
        <a href="/residents/password-reset">Reset your password</a>
      </div>
    );
  }
}

export default ResidentsLogin;
