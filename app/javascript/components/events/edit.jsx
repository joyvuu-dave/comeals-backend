import React, { Component } from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from "react-day-picker/DayPickerInput";
import { formatDate, parseDate } from "react-day-picker/moment";
import moment from "moment";
import axios from "axios";
import Cookie from "js-cookie";
import { generateTimes } from "../../helpers/helpers";
import { inject } from "mobx-react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";

const EventsEdit = inject("store")(
  class EventsEdit extends Component {
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
        event: {}
      };
    }

    componentDidMount() {
      var host = `${window.location.protocol}//`;
      var topLevel = window.location.hostname.split(".");
      topLevel = `.${topLevel[topLevel.length - 1]}`;

      var self = this;
      axios
        .get(
          `${host}api.comeals${topLevel}/api/v1/events/${
            self.props.eventId
          }?token=${Cookie.get("token")}`
        )
        .then(function(response) {
          if (response.status === 200) {
            self.setState({
              event: response.data,
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
          `${self.state.host}api.comeals${self.state.topLevel}/api/v1/events/${
            self.props.eventId
          }/update?token=${Cookie.get("token")}`,
          {
            title: values.title,
            description: values.description,
            start_year: values.day && new Date(values.day).getFullYear(),
            start_month: values.day && new Date(values.day).getMonth() + 1,
            start_day: values.day && new Date(values.day).getDate(),
            start_hours: values.start_time && values.start_time.split(":")[0],
            start_minutes: values.start_time && values.start_time.split(":")[1],
            end_hours: values.end_time && values.end_time.split(":")[0],
            end_minutes: values.end_time && values.end_time.split(":")[1],
            all_day: values.all_day
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
      if (window.confirm("Do you really want to delete this event?")) {
        var self = this;
        axios
          .delete(
            `${self.state.host}api.comeals${
              self.state.topLevel
            }/api/v1/events/${self.state.event.id}/delete?token=${Cookie.get(
              "token"
            )}`
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
          value={formatDate(this.state.event.start_date)}
        />
      );
    }

    attachDispatch(dispatch) {
      this.formDispatch = dispatch;
    }

    getInitialEndTime() {
      if (this.state.event.end_date === null) {
        return "";
      }

      return `${new Date(this.state.event.end_date)
        .getHours()
        .toString()
        .padStart(2, "0")}:${new Date(this.state.event.end_date)
        .getMinutes()
        .toString()
        .padStart(2, "0")}`;
    }

    render() {
      return (
        <div>
          {this.state.ready && (
            <div>
              <div className="flex">
                <h2>Event</h2>
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
                    title: this.state.event.title,
                    description: this.state.event.description,
                    day: this.state.event.start_date,
                    start_time: `${new Date(this.state.event.start_date)
                      .getHours()
                      .toString()
                      .padStart(2, "0")}:${new Date(this.state.event.start_date)
                      .getMinutes()
                      .toString()
                      .padStart(2, "0")}`,
                    end_time: this.getInitialEndTime(),
                    all_day: this.state.event.allday
                  }}
                >
                  <label>Title</label>
                  <Control.text model=".title" />
                  <br />
                  <label>Description</label>
                  <Control.textarea
                    model=".description"
                    placeholder="optional"
                  />
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
                  <label>Start Time</label>
                  <Control.select
                    model="local.start_time"
                    id="local.start_time"
                  >
                    <option />
                    {generateTimes().map(time => (
                      <option key={time.value} value={time.value}>
                        {time.display}
                      </option>
                    ))}
                  </Control.select>
                  <br />
                  <label>End Time</label>
                  <Control.select model="local.end_time" id="local.end_time">
                    <option />
                    {generateTimes().map(time => (
                      <option key={time.value} value={time.value}>
                        {time.display}
                      </option>
                    ))}
                  </Control.select>
                  <br />
                  <label>All Day</label>
                  {"  "}
                  <Control.checkbox model="local.all_day" id="local.all_day" />
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

export default EventsEdit;
