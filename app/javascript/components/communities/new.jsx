import React from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";

class CommunitiesNew extends React.Component {
  handleChange(values) {}
  handleUpdate(form) {}
  handleSubmit(values) {
    axios
      .post(`${window.host}api.comeals${window.topLevel}/api/v1/communities`, {
        name: values.name
      })
      .then(function(response) {
        if (response.status === 200) {
          window.location.href = `/communities/${response.data.id}`;
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
        <LocalForm
          onUpdate={form => this.handleUpdate(form)}
          onChange={values => this.handleChange(values)}
          onSubmit={values => this.handleSubmit(values)}
        >
          <label>name</label>
          <Control.text model=".name" />
          <br />

          <button type="submit">Submit</button>
        </LocalForm>
      </div>
    );
  }
}

export default CommunitiesNew;
