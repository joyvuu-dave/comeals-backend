import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class ResidentsProfile extends Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post(
        `${window.host}api.comeals${window.topLevel}/api/v1/residents/profile`,
        {
          name: values.name,
          birthday: values.birthday,
          email: values.email,
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${window.host}admin.comeals${
            window.topLevel
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
      <div>
        <h2>Edit Your Profile</h2>
        <fieldset className="w-50">
          <legend>Profile</legend>
          <LocalForm
            onUpdate={form => this.handleUpdate(form)}
            onChange={values => this.handleChange(values)}
            onSubmit={values => this.handleSubmit(values)}
          >
            <label>Name</label>
            <Control.text model=".name" className="w-75" />
            <br />

            <label>Birthday</label>
            <Control.text model=".birthday" className="w-75" />
            <br />

            <label>Email Address</label>
            <Control.text model=".email" className="w-75" />
            <br />

            <label>Password</label>
            <Control type="password" model=".password" className="w-75" />
            <br />

            <button type="submit">Submit</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default ResidentsProfile;
