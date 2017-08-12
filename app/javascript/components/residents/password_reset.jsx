import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class ResidentsPasswordReset extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post(
        `${window.host}api.comeals${window.topLevel}/api/v1/residents/password-reset`,
        {
          email: values.email
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.alert(response.data.message);
          window.location.href = `${window.host}www.comeals${window.topLevel}`;
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
        <fieldset className="width-50">
          <legend>Password Reset</legend>
          <label className="width-75">
            <Control.text
              model=".email"
              placeholder="Email"
              autoCapitalize="none"
            />
          </label>
        </fieldset>

        <button type="submit">Submit</button>
      </LocalForm>
    );
  }
}

export default ResidentsPasswordReset;
