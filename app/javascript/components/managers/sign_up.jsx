import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";

class ManagersSignUp extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post("http://api.comeals.dev/api/v1/managers", {
        email: values.email,
        password: values.password
      })
      .then(function(response) {
        if (response.status === 200) {
          Cookie.set("token", response.data.token, {
            expires: 7300,
            domain: ".comeals.dev"
          });
          window.location.href = `/manager/${response.data.id}`;
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
        <label>email</label>
        <Control.text model=".email" />
        <br />

        <label>password</label>
        <Control type="password" model=".password" />
        <br />

        <button type="submit">Submit</button>
      </LocalForm>
    );
  }
}

export default ManagersSignUp;
