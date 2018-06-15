import React, { Component } from "react";
import { LocalForm, Control } from "react-redux-form";
import axios from "axios";
import Cookie from "js-cookie";
import { Link } from "react-router-dom";
import Modal from "react-modal";

import ResidentsPasswordReset from "./password_reset";
import CommunitiesNew from "../../components/communities/new";
import ResidentsPasswordNew from "./password_new";

import Footer from "../app/footer";

Modal.setAppElement("#main");
class ResidentsLogin extends Component {
  constructor(props) {
    super(props);

    var topLevel = window.location.hostname.split(".");
    topLevel = topLevel[topLevel.length - 1];

    this.state = {
      host: `${window.location.protocol}//`,
      topLevel: `.${topLevel}`,
      createCommunityVisible: false
    };

    this.handleCloseModal = this.handleCloseModal.bind(this);
  }

  renderModal() {
    if (typeof this.props.match.params.modal === "undefined") {
      return null;
    }

    switch (this.props.match.params.modal) {
      case "reset-password":
        if (typeof this.props.match.params.token === "undefined") {
          return (
            <ResidentsPasswordReset
              handleCloseModal={this.handleCloseModal}
              history={this.props.history}
            />
          );
        } else {
          return (
            <ResidentsPasswordNew
              handleCloseModal={this.handleCloseModal}
              history={this.props.history}
              match={this.props.match}
            />
          );
        }
        break;

      case "create-community":
        return (
          <CommunitiesNew
            handleCloseModal={this.handleCloseModal}
            history={this.props.history}
          />
        );
        break;

      default:
        return null;
    }
  }

  handleCloseModal() {
    this.props.history.push("/");
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
        <header className="flex space-between header">
          <h2 className="pad-l-sm">Comeals</h2>
          <span id="status" />
          <a
            href={`${this.state.host}admin.comeals${this.state.topLevel}`}
            className="pad-r-sm text-secondary"
          >
            admin
          </a>
        </header>
        <div className="box">
          <br />
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
            <Link to="/reset-password" className="text-black">
              Reset your password
            </Link>
          </div>
          <div>
            <br />
            <br />
            <br />
            <br />
            <div className="w-50">
              <h3 className="text-black">Add your Community</h3>
              <p className="text-black">
                Start managing your common meals today!
              </p>
              <Link className="button" to="/create-community">
                Sign Up
              </Link>
            </div>
          </div>
        </div>
        <Footer />
        <Modal
          isOpen={typeof this.props.match.params.modal !== "undefined"}
          contentLabel="Login Modal"
          onRequestClose={this.handleCloseModal}
          style={{
            content: {
              backgroundColor: "#6699cc"
            }
          }}
        >
          {this.renderModal()}
        </Modal>
      </div>
    );
  }
}

export default ResidentsLogin;
