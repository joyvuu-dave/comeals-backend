import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";

class CommunitiesNew extends Component {
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
        `${myState.host}api.comeals${myState.topLevel}/api/v1/communities`,
        {
          name: values.name,
          email: values.email,
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `${myState.host}admin.comeals${
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
      <div>
        <h2>Create a new Community</h2>
        <fieldset className="w-50">
          <legend>Community</legend>
          <LocalForm onSubmit={values => this.handleSubmit(values)}>
            <label>Community Name</label>
            <Control.text model=".name" className="w-75" />
            <br />

            <label>Admin Email Address</label>
            <Control.text model=".email" className="w-75" />
            <br />

            <label>Admin Password</label>
            <Control type="password" model=".password" className="w-75" />
            <br />

            <button type="submit">Submit</button>
          </LocalForm>
        </fieldset>
      </div>
    );
  }
}

export default CommunitiesNew;
