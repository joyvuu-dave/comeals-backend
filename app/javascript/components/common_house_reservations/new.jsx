import React, { Component } from "react";
import { LocalForm, Control, actions } from "react-redux-form";
import DayPickerInput from "react-day-picker/DayPickerInput";
import { formatDate, parseDate } from "react-day-picker/moment";
import moment from "moment";
import axios from "axios";
import Cookie from "js-cookie";
import { inject } from "mobx-react";
import { generateTimes } from "../../helpers/helpers";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";

const CommonHouseReservationsNew = inject("store")(
  class CommonHouseReservationsNew extends Component {
    constructor(props) {
      super(props);
      this.handleDayChange = this.handleDayChange.bind(this);

      var topLevel = window.location.hostname.split(".");
      topLevel = topLevel[topLevel.length - 1];

      this.state = {
        host: `${window.location.protocol}//`,
        topLevel: `.${topLevel}`,
        slug: window.location.hostname.split(".")[0],
        communityId: Cookie.get("community_id"),
        residents: [],
        ready: false
      };
    }

    componentDidMount() {
      var self = this;
      axios
        .get(
          `${self.state.host}api.comeals${
            self.state.topLevel
          }/api/v1/communities/${
            self.state.communityId
          }/hosts?token=${Cookie.get("token")}`
        )
        .then(function(response) {
          if (response.status === 200) {
            self.setState({
              residents: response.data,
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
        .post(
          `${self.state.host}api.comeals${
            self.state.topLevel
          }/api/v1/common-house-reservations?community_id=${
            self.state.communityId
          }&token=${Cookie.get("token")}`,
          {
            resident_id: values.resident_id,
            start_year: values.day && values.day.getFullYear(),
            start_month: values.day && values.day.getMonth() + 1,
            start_day: values.day && values.day.getDate(),
            start_hours:
              values && values.start_time && values.start_time.split(":")[0],
            start_minutes:
              values && values.start_time && values.start_time.split(":")[1],
            end_hours:
              values && values.end_time && values.end_time.split(":")[0],
            end_minutes:
              values && values.end_time && values.end_time.split(":")[1],
            title: values && values.title
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

    handleDayChange(val) {
      this.formDispatch(actions.change("local.day", val));
    }

    getDayPickerInput() {
      return (
        <DayPickerInput
          formatDate={formatDate}
          parseDate={parseDate}
          placeholder={""}
          onDayChange={this.handleDayChange}
          dayPickerProps={{
            initialMonth: moment(this.props.match.params.date).toDate()
          }}
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
                <h2>Common House</h2>
                <FontAwesomeIcon
                  icon={faTimes}
                  size="2x"
                  className="close-button"
                  onClick={this.props.handleCloseModal}
                />
              </div>
              <fieldset>
                <legend>New</legend>
                <LocalForm
                  onSubmit={values => this.handleSubmit(values)}
                  getDispatch={dispatch => this.attachDispatch(dispatch)}
                >
                  <label>Resident</label>
                  <Control.select model=".resident_id" id="local.resident_id">
                    <option />
                    {this.state.residents.map(resident => (
                      <option key={resident[0]} value={resident[0]}>
                        {resident[2]} - {resident[1]}
                      </option>
                    ))}
                  </Control.select>
                  <br />
                  <label>Title</label>
                  <br />
                  <Control.text
                    model="local.title"
                    id="local.title"
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

                  <button type="submit" className="button-dark">
                    Create
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

export default CommonHouseReservationsNew;
