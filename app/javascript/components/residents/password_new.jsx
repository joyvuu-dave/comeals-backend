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
      topLevel: `.${topLevel}`,
      ready: false,
      name: ""
    };
  }

  componentDidMount() {
    var self = this;
    axios
      .get(
        `${self.state.host}api.comeals${
          self.state.topLevel
        }/api/v1/residents/name/${self.props.match.params.token}`
      )
      .then(function(response) {
        if (response.status === 200) {
          self.setState({
            name: response.data.name,
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
          self.props.history.push("/");
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

  handleSubmit(values) {
    var self = this;

    axios
      .post(
        `${self.state.host}api.comeals${
          self.state.topLevel
        }/api/v1/residents/password-reset/${self.props.match.params.token}`,
        {
          password: values.password
        }
      )
      .then(function(response) {
        if (response.status === 200) {
          window.alert(response.data.message);
          self.props.history.push("/");
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
          self.props.history.push("/");
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
        {this.state.ready && (
          <LocalForm onSubmit={values => this.handleSubmit(values)}>
            <fieldset className="w-100">
              <legend>Reset Password for {this.state.name}</legend>
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
        )}
        {!this.state.ready && <h3>Loading...</h3>}
      </div>
    );
  }
}

export default ResidentsPasswordNew;
