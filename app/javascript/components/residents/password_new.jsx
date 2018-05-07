import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class ResidentsPasswordNew extends Component {
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
        `${myState.host}api.comeals${
          myState.topLevel
        }/api/v1/residents/password-reset/${this.props.token}`,
        {
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.alert(response.data.message);
          window.location.href = `${myState.host}www.comeals${
            myState.topLevel
          }`;
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
      <LocalForm
        onUpdate={form => this.handleUpdate(form)}
        onChange={values => this.handleChange(values)}
        onSubmit={values => this.handleSubmit(values)}
      >
        <fieldset className="w-50">
          <legend>Reset Password for {this.props.email}</legend>
          <label className="w-75">
            <Control
              type="password"
              model=".password"
              placeholder="New Password"
            />
          </label>
        </fieldset>

        <button type="submit">Submit</button>
      </LocalForm>
    );
  }
}

export default ResidentsPasswordNew;
