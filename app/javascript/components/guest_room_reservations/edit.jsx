import React, { Component } from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from "react-day-picker/DayPickerInput";
import { formatDate, parseDate } from "react-day-picker/moment";
import moment from "moment";
import axios from "axios";
import Cookie from "js-cookie";
import { inject } from "mobx-react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";

const GuestRoomReservationsEdit = inject("store")(
  class GuestRoomReservationsEdit extends Component {
    constructor(props) {
      super(props);
      this.handleDayChange = this.handleDayChange.bind(this);

      var topLevel = window.location.hostname.split(".");
      topLevel = topLevel[topLevel.length - 1];

      this.state = {
        host: `${window.location.protocol}//`,
        topLevel: `.${topLevel}`,
        slug: window.location.hostname.split(".")[0],
        ready: false,
        event: {},
        hosts: []
      };
    }

    componentDidMount() {
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      var self = this;
      axios
        .get(
          `${host}api.comeals${topLevel}/api/v1/guest-room-reservations/${
            self.props.eventId
          }?token=${Cookie.get("token")}`
        )
        .then(function(response) {
          if (response.status === 200) {
            self.setState({
              event: response.data.event,
              hosts: response.data.hosts
            });
            self.setState({ ready: true });
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

    handleSubmit(values) {
      var self = this;
      axios
        .patch(
          `${self.state.host}api.comeals${
            self.state.topLevel
          }/api/v1/guest-room-reservations/${
            self.props.eventId
          }/update?token=${Cookie.get("token")}`,
          {
            resident_id: values.resident_id,
            date: values.day
          }
        )
        .then(function(response) {
          if (response.status === 200) {
            self.props.handleCloseModal();
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

    handleDelete() {
      if (window.confirm("Do you really want to delete this reservation?")) {
        var self = this;
        axios
          .delete(
            `${self.state.host}api.comeals${
              self.state.topLevel
            }/api/v1/guest-room-reservations/${
              self.props.eventId
            }/delete?token=${Cookie.get("token")}`
          )
          .then(function(response) {
            if (response.status === 200) {
              self.props.handleCloseModal();
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
    }

    handleDayChange(val) {
      this.formDispatch(actions.change("local.day", val));
    }

    getDayPickerInput() {
      return (
        <DayPickerInput
          formatDate={formatDate}
          parseDate={parseDate}
          onDayChange={this.handleDayChange}
          value={formatDate(this.state.event.date)}
        />
      );
    }

    attachDispatch(dispatch) {
      this.formDispatch = dispatch;
    }

    render() {
      return (
        <div>
          {this.state.ready && (
            <div>
              <div className="flex">
                <h2>Guest Room Reservation</h2>
                <button
                  onClick={this.handleDelete.bind(this)}
                  type="button"
                  className="mar-md button-warning"
                >
                  Delete
                </button>
                <FontAwesomeIcon
                  icon={faTimes}
                  size="2x"
                  className="close-button"
                  onClick={this.props.handleCloseModal}
                />
              </div>
              <fieldset>
                <legend>Edit</legend>
                <LocalForm
                  onSubmit={values => this.handleSubmit(values)}
                  getDispatch={dispatch => this.attachDispatch(dispatch)}
                  initialState={{
                    resident_id: this.state.event.resident_id,
                    day: this.state.event.date
                  }}
                >
                  <label>Host</label>
                  <Control.select model=".resident_id" id="local.resident_id">
                    {this.state.hosts.map(host => (
                      <option key={host[0]} value={host[0]}>
                        {host[2]} - {host[1]}
                      </option>
                    ))}
                  </Control.select>
                  <br />

                  <label>Day</label>
                  <br />
                  <Control.text
                    model="local.day"
                    id="local.day"
                    component={this.getDayPickerInput.bind(this)}
                  />
                  <br />
                  <br />

                  <button type="submit" className="button-dark">
                    Update
                  </button>
                </LocalForm>
              </fieldset>
            </div>
          )}
          {!this.state.ready && <h3>Loading...</h3>}
        </div>
      );
    }
  }
);

export default GuestRoomReservationsEdit;
